package funnel;

import java.io.InputStream;
import java.io.OutputStream;
import java.util.Arrays;
import java.util.Enumeration;
import java.util.TooManyListenersException;
import java.util.Vector;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.TimeUnit;

import com.illposed.osc.OSCBundle;
import com.illposed.osc.OSCMessage;

import gnu.io.CommPortIdentifier;
import gnu.io.SerialPort;
import gnu.io.SerialPortEventListener;

public abstract class FirmataIO extends IOModule implements
		SerialPortEventListener {

	private static final int ARD_MAX_DATA_BYTES = 3;
	private static final int ARD_ANALOG_MESSAGE = 0xE0;
	private static final int ARD_DIGITAL_MESSAGE = 0x90;
	private static final int ARD_REPORT_ANALOG_PIN = 0xC0;
	private static final int ARD_REPORT_DIGITAL_PORTS = 0xD0;
	private static final int ARD_SET_DIGITAL_PIN_MODE = 0xF4;
	private static final int ARD_REPORT_VERSION = 0xF9;
	// private static final int ARD_SYSTEM_RESET = 0xFF;
	protected static final int ARD_PIN_MODE_IN = 0x00;
	protected static final int ARD_PIN_MODE_OUT = 0x01;
	protected static final int ARD_PIN_MODE_PWM = 0x02;
	protected static final int ARD_PIN_MODE_AIN = 0x03;

	protected int totalAnalogPins = 6;
	protected int totalDigitalPins = 14;
	protected int totalPins = totalAnalogPins + totalDigitalPins;
	protected int[] pwmCapablePins = null;
	protected SerialPort port;
	protected InputStream input;
	protected OutputStream output;
	protected final int rate = 57600;
	protected final int parity = SerialPort.PARITY_NONE;
	protected final int databits = 8;
	protected final int stopbits = SerialPort.STOPBITS_1;
	protected int bytesToReceive = 0;
	protected int executeMultiByteCommand = 0;
	protected int multiByteChannel = 0;
	protected int[] storedInputData = new int[ARD_MAX_DATA_BYTES];
	protected float[] analogData = null;
	protected float[] digitalData = null;
	protected int[] pinMode = new int[totalPins];
	protected int[] firmwareVersion = new int[ARD_MAX_DATA_BYTES];
	private int stateOfDigitalPins = 0x0000;
	protected funnel.PortRange analogPinRange;
	protected funnel.PortRange digitalPinRange;
	protected Vector<PortRange> dinPinChunks;
	protected final Float FLOAT_ZERO = new Float(0.0f);
	protected BlockingQueue<String> firmwareVersionQueue;

	public FirmataIO(int analogPins, int digitalPins, int[] pwmPins) {
		super();

		totalAnalogPins = analogPins;
		totalDigitalPins = digitalPins;
		totalPins = totalAnalogPins + totalDigitalPins;
		pwmCapablePins = (int[]) pwmPins.clone();

		analogData = new float[totalAnalogPins];
		digitalData = new float[totalDigitalPins];
		pinMode = new int[totalPins];
		firmwareVersionQueue = new LinkedBlockingQueue<String>(1);

		analogPinRange = new funnel.PortRange();
		analogPinRange.setRange(0, totalAnalogPins - 1);
		digitalPinRange = new funnel.PortRange();
		digitalPinRange.setRange(totalAnalogPins, totalPins - 1);
		dinPinChunks = new Vector<PortRange>();
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see funnel.IOModule#dispose()
	 */
	public void dispose() {
		port.removeEventListener();
		printMessage(Messages.getString("IOModule.Disposing")); //$NON-NLS-1$
		try {
			if (input != null)
				input.close();
			if (output != null)
				output.close();
		} catch (Exception e) {
			e.printStackTrace();
		}
		input = null;
		output = null;

		try {
			if (port != null)
				port.close();
		} catch (Exception e) {
			e.printStackTrace();
		}
		port = null;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see funnel.IOModule#getInputs(java.lang.String, java.lang.Object[])
	 */
	public Object[] getInputs(String address, Object[] arguments)
			throws IllegalArgumentException {
		int moduleId = 0;
		int from = 0;
		int counts = 0;
		int totalPortCounts = analogPinRange.getCounts()
				+ digitalPinRange.getCounts();

		if (address.equals("/in")) { //$NON-NLS-1$
			moduleId = ((Integer) arguments[0]).intValue();
			from = ((Integer) arguments[1]).intValue();
			counts = ((Integer) arguments[2]).intValue();
		} else if (address.equals("/in/*")) { //$NON-NLS-1$
			moduleId = ((Integer) arguments[0]).intValue();
			from = 0;
			counts = totalPortCounts;
		}

		if ((from + counts) > totalPortCounts) {
			counts = totalPortCounts - from;
		}

		if ((from >= totalPortCounts) || (counts <= 0)) {
			throw new IllegalArgumentException(""); //$NON-NLS-1$
		}

		Object[] results = new Object[2 + counts];
		results[0] = new Integer(moduleId);
		results[1] = new Integer(from);
		for (int i = 0; i < counts; i++) {
			int port = from + i;
			if (digitalPinRange.contains(port)) {
				results[2 + i] = new Float(digitalData[port
						- digitalPinRange.getMin()]);
			} else if (analogPinRange.contains(port)) {
				results[2 + i] = new Float(analogData[port
						- analogPinRange.getMin()]);
			}
		}
		return results;
	}

	public void notifyUpdate(int from, int counts) {
		Object[] results = new Object[2 + counts];
		results[0] = new Integer(0); // TODO: Support multiple modules
		results[1] = new Integer(from);
		for (int i = 0; i < counts; i++) {
			int port = from + i;
			if (digitalPinRange.contains(port)) {
				results[2 + i] = new Float(digitalData[port
						- digitalPinRange.getMin()]);
			} else if (analogPinRange.contains(port)) {
				results[2 + i] = new Float(analogData[port
						- analogPinRange.getMin()]);
			}
		}

		OSCMessage message = new OSCMessage("/in", results);
		parent.getCommandPortServer().sendMessageToClients(message);
	}

	public OSCBundle getAllInputsAsBundle() {
		if (!isPolling) {
			return null;
		}

		OSCBundle bundle = new OSCBundle();

		Object ainArguments[] = new Object[2 + analogPinRange.getCounts()];
		ainArguments[0] = new Integer(0);
		ainArguments[1] = new Integer(analogPinRange.getMin());
		for (int i = 0; i < analogPinRange.getCounts(); i++) {
			ainArguments[2 + i] = new Float(analogData[i]);
		}
		bundle.addPacket(new OSCMessage("/in", ainArguments)); //$NON-NLS-1$

		for (int j = 0; j < dinPinChunks.size(); j++) {
			PortRange range = dinPinChunks.get(j);
			Object dinArguments[] = new Object[2 + range.getCounts()];
			dinArguments[0] = new Integer(0);
			dinArguments[1] = new Integer(range.getMin());
			int offset = range.getMin() - digitalPinRange.getMin();
			for (int i = 0; i < range.getCounts(); i++) {
				dinArguments[2 + i] = new Float(digitalData[offset + i]);
			}
			bundle.addPacket(new OSCMessage("/in", dinArguments)); //$NON-NLS-1$
		}

		return bundle;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see funnel.IOModule#reboot()
	 */
	public void reboot() {
		if (port == null) {
			return;
		}
		stopPolling();

		printMessage(Messages.getString("IOModule.Rebooting")); //$NON-NLS-1$

		// NOTE:
		// In Firmata 2.0 beta 0, the system reset command will remove all
		// callbacks. So don't use the command here, or your I/O board will stop
		// responding
		// 
		// writeByte(ARD_SYSTEM_RESET);
		sleep(500);

		writeByte(ARD_REPORT_VERSION);
		try {
			firmwareVersionQueue.poll(10000, TimeUnit.MILLISECONDS);
		} catch (InterruptedException e) {
			printMessage("ERROR: Couldn't get a version info after rebooting.");
			e.printStackTrace();
		}
		printMessage(Messages.getString("IOModule.Rebooted")); //$NON-NLS-1$
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see funnel.IOModule#setConfiguration(java.lang.Object[])
	 */
	public void setConfiguration(Object[] arguments) {
		if (isPolling) {
			stopPolling();
			sleep(100);
		}

		int moduleId = ((Integer) arguments[0]).intValue();
		printMessage("Module ID: " + moduleId);
		Object[] config = new Object[arguments.length - 1];
		System.arraycopy(arguments, 1, config, 0, arguments.length - 1);

		// TODO
		// Should synchronize with the notification thread
		dinPinChunks.clear();

		if (config.length != totalPins) {
			throw new IllegalArgumentException(
					"The number of pins does not match to that of the Arduino I/O module"); //$NON-NLS-1$
		}

		// beginPacketIfNeeded(moduleId);
		for (int i = 0; i < config.length; i++) {
			if (config[i] == null) {
				throw new IllegalArgumentException(
						"Argument of the following port is null: " + i);
			}
			if (!(config[i] instanceof Integer)) {
				throw new IllegalArgumentException(
						"Argument of the following port is not an integer value: "
								+ i);
			}
			if (analogPinRange.contains(i)) {
				if (!PORT_AIN.equals(config[i])) {
					throw new IllegalArgumentException(
							"Only AIN is available on the following port: " + i);
				}
				pinMode[i] = ARD_PIN_MODE_AIN;
			} else if (digitalPinRange.contains(i)) {
				if (PORT_AOUT.equals(config[i])) {
					if (Arrays.binarySearch(pwmCapablePins, i) < 0) {
						throw new IllegalArgumentException(
								"AOUT is not available on the following port: "
										+ i);
					}
					setPinMode(i - digitalPinRange.getMin(), ARD_PIN_MODE_PWM);
					pinMode[i] = ARD_PIN_MODE_PWM;
				} else if (PORT_DIN.equals(config[i])) {
					setPinMode(i - digitalPinRange.getMin(), ARD_PIN_MODE_IN);
					pinMode[i] = ARD_PIN_MODE_IN;
				} else if (PORT_DOUT.equals(config[i])) {
					setPinMode(i - digitalPinRange.getMin(), ARD_PIN_MODE_OUT);
					pinMode[i] = ARD_PIN_MODE_OUT;
				} else {
					throw new IllegalArgumentException(
							"A wrong port mode is specified for the following port: "
									+ i);
				}
			}
		}
		// endPacketIfNeeded();

		boolean wasNotInput = true;
		int from = 0;
		int to = 0;
		for (int i = digitalPinRange.getMin(); i <= digitalPinRange.getMax(); i++) {
			if (wasNotInput && pinMode[i] == ARD_PIN_MODE_IN) {
				from = i;
				wasNotInput = false;
			} else if (!wasNotInput && pinMode[i] != ARD_PIN_MODE_IN) {
				to = i - 1;
				PortRange range = new PortRange();
				range.setRange(from, to);
				dinPinChunks.add(range);
				wasNotInput = true;
			}
		}

		// process the last block
		if (pinMode[digitalPinRange.getMax()] == ARD_PIN_MODE_IN) {
			to = digitalPinRange.getMax();
			PortRange range = new PortRange();
			range.setRange(from, to);
			dinPinChunks.add(range);
		}

		if (dinPinChunks != null) {
			for (int i = 0; i < dinPinChunks.size(); i++) {
				PortRange range = dinPinChunks.get(i);
				printMessage("digital inputs: [" + range.getMin() + ".."
						+ range.getMax() + "]");
			}
		}
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see funnel.IOModule#setOutput(java.lang.Object[])
	 */
	public void setOutput(Object[] arguments) {
		// printMessage("arguments: " + arguments[0] + ", " + arguments[1] + ",
		// "
		// + arguments[2]);
		// //$NON-NLS-1$ //$NON-NLS-2$
		int moduleId = ((Integer) arguments[0]).intValue();
		int start = ((Integer) arguments[1]).intValue();

		beginPacketIfNeeded(moduleId);
		for (int i = 0; i < (arguments.length - 2); i++) {
			int port = start + i;
			int index = 2 + i;
			if (digitalPinRange.contains(port)) {
				// converts from global pin number to local pin number
				// e.g. global pin number 6 means local pin number 0
				int pin = port - digitalPinRange.getMin();

				if (arguments[index] != null
						&& arguments[index] instanceof Float) {
					if (pinMode[port] == ARD_PIN_MODE_OUT) {
						digitalWrite(pin,
								FLOAT_ZERO.equals(arguments[index]) ? 0 : 1);
					} else if (pinMode[port] == ARD_PIN_MODE_PWM) {
						analogWrite(pin, ((Float) arguments[index])
								.floatValue());
					}
				}
			}
		}
		endPacketIfNeeded();
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see funnel.IOModule#setPolling(java.lang.Object[])
	 */
	public void setPolling(Object[] arguments) {
		if (arguments[0] instanceof Integer) {
			if (new Integer(1).equals(arguments[0])) {
				startPolling();
			} else {
				stopPolling();
			}
		} else {
			throw new IllegalArgumentException(
					"The first argument of /polling is not an integer value"); //$NON-NLS-1$
		}
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see funnel.IOModule#stopPolling()
	 */
	public void startPolling() {
		if (port == null) {
			return;
		}

		beginPacketIfNeeded(0xFFFF);
		for (int pin = 0; pin < totalAnalogPins; pin++) {
			setAnalogPinReporting(pin, 1);
		}
		enableDigitalPinReporting();
		endPacketIfNeeded();
		isPolling = true;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see funnel.IOModule#stopPolling()
	 */
	public void stopPolling() {
		if (port == null) {
			return;
		}

		isPolling = false;
		beginPacketIfNeeded(0xFFFF);
		for (int pin = 0; pin < totalAnalogPins; pin++) {
			setAnalogPinReporting(pin, 0);
		}
		disableDigitalPinReporting();
		endPacketIfNeeded();
	}

	protected void begin(String serialPortName, int baudRate) {
		printMessage(Messages.getString("IOModule.Starting")); //$NON-NLS-1$

		try {
			Enumeration<?> portList = CommPortIdentifier.getPortIdentifiers();

			while (portList.hasMoreElements()) {
				CommPortIdentifier portId = (CommPortIdentifier) portList
						.nextElement();

				if (portId.getPortType() == CommPortIdentifier.PORT_SERIAL) {
					if (portId.getName().equals(serialPortName)) {
						port = (SerialPort) portId.open("serial firmata", 2000); //$NON-NLS-1$
						input = port.getInputStream();
						output = port.getOutputStream();
						if (baudRate > 0) {
							parent.printMessage("baudrate: " + baudRate);
							port.setSerialPortParams(baudRate, databits,
									stopbits, parity);
						} else {
							port.setSerialPortParams(rate, databits, stopbits,
									parity);
						}
						port.notifyOnDataAvailable(true);
					}
				}
			}
			if (port == null) {
				printMessage(Messages.getString("IOModule.PortNotFoundError")); //$NON-NLS-1$
			}
		} catch (Exception e) {
			printMessage(Messages.getString("IOModule.InsideSerialError")); //$NON-NLS-1$
			e.printStackTrace();
			port = null;
			input = null;
			output = null;
		}

		try {
			port.addEventListener(this);
			printMessage(Messages.getString("IOModule.Started") //$NON-NLS-1$
					+ serialPortName);
		} catch (TooManyListenersException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	protected void processInput(int inputData) {
		int command = 0;

		if (inputData < 0)
			inputData = 256 + inputData;

		// We have data
		if (bytesToReceive > 0 && inputData < 128) {
			bytesToReceive--;

			storedInputData[bytesToReceive] = inputData;
			if ((executeMultiByteCommand != 0) && (bytesToReceive == 0)) {
				// We got everything
				switch (executeMultiByteCommand) {
				case ARD_DIGITAL_MESSAGE:
					processDigitalBytes(multiByteChannel,
							((storedInputData[0] << 7) | storedInputData[1]));
					// TODO: Optimize here to do not report twice
					for (int j = 0; j < dinPinChunks.size(); j++) {
						PortRange range = dinPinChunks.get(j);
						notifyUpdate(range.getMin(), range.getCounts());
					}
					break;
				case ARD_REPORT_VERSION: // Report version
					firmwareVersion[0] = storedInputData[0]; // minor
					firmwareVersion[1] = storedInputData[1]; // major
					printMessage("Firmata Protocol Vesrion: "
							+ firmwareVersion[1] + "." + firmwareVersion[0]);
					firmwareVersionQueue.add(firmwareVersion[1] + "."
							+ firmwareVersion[0]);
					break;
				case ARD_ANALOG_MESSAGE:
					analogData[multiByteChannel] = (float) ((storedInputData[0] << 7) | storedInputData[1]) / 1023.0f;
					if (multiByteChannel == analogPinRange.getMax()) {
						notifyUpdate(analogPinRange.getMin(), analogPinRange
								.getCounts());
					}
					break;
				}

			}
		} else {
			// We have a command
			// remove channel info from command byte if less than
			// 0xF0
			if (inputData < 240) {
				command = inputData & 240;
				multiByteChannel = inputData & 15;
			} else {
				// commands in the 0xF* range don't use channel data
				command = inputData;
			}

			switch (command) {
			case ARD_REPORT_VERSION:
			case ARD_DIGITAL_MESSAGE:
			case ARD_ANALOG_MESSAGE:
				bytesToReceive = 2; // 3 bytes needed
				executeMultiByteCommand = command;
				break;
			}
		}
	}

	protected void processDigitalBytes(int port, int value) {
		int mask;

		switch (port) {
		case 0: // D0 - D7
			// ignore Rx,Tx pins (0 and 1)
			for (int i = 2; i < 8; ++i) {
				mask = 1 << i;
				digitalData[i] = (float) ((value & mask) >> i);
			}
			break;
		case 1: // D8 - D13
			for (int i = 8; i < totalDigitalPins; ++i) {
				mask = 1 << i;
				digitalData[i] = (float) ((value & mask) >> i);
			}
			break;
		default:
			break;
		}
	}

	protected void setAnalogPinReporting(int pin, int mode) {
		writeByte(ARD_REPORT_ANALOG_PIN + pin);
		writeByte(mode);
	}

	protected void enableDigitalPinReporting() {
		writeByte(ARD_REPORT_DIGITAL_PORTS | 0x00);
		writeByte(1);
		writeByte(ARD_REPORT_DIGITAL_PORTS | 0x01);
		writeByte(1);
	}

	protected void disableDigitalPinReporting() {
		writeByte(ARD_REPORT_DIGITAL_PORTS | 0x00);
		writeByte(0);
		writeByte(ARD_REPORT_DIGITAL_PORTS | 0x01);
		writeByte(0);
	}

	protected void setPinMode(int pin, int mode) {
		writeByte(ARD_SET_DIGITAL_PIN_MODE);
		writeByte(pin);
		writeByte(mode);
	}

	protected void digitalWrite(int pin, int mode) {
		int bitMask = 1 << pin;

		if (mode == 1) {
			stateOfDigitalPins |= bitMask;
		} else if (mode == 0) {
			stateOfDigitalPins &= ~bitMask;
		}

		int port = -1;
		if (pin < 8) {
			port = 0;
		} else if (pin < 16) {
			port = 1;
		} else if (pin < 24) {
			port = 2;
		}

		switch (port) {
		case 0:
			writeByte(ARD_DIGITAL_MESSAGE | port);
			writeByte(stateOfDigitalPins & 0x7F); // digital pins 0-6
			writeByte((stateOfDigitalPins & 0x0080) >> 7); // digital pins 7
			break;
		case 1:
			writeByte(ARD_DIGITAL_MESSAGE | port);
			writeByte((stateOfDigitalPins >> 8) & 0x7F); // digital pins 8-14
			writeByte((stateOfDigitalPins & 0x8000) >> 15); // digital pins 15
			break;
		case 2:
			// TODO: Support digitalWrite to analog pins
			break;
		default:
			break;
		}
	}

	protected void analogWrite(int pin, float value) {
		int intValue = Math.round(value * 255.0f);
		intValue = (intValue < 0) ? 0 : intValue;
		intValue = (intValue > 255) ? 255 : intValue;

		writeByte(ARD_ANALOG_MESSAGE + pin);
		writeByte(intValue % 128);
		writeByte(intValue >> 7);
	}

	protected void beginPacketIfNeeded(int destinationId) {
		// Nothing to do except for Funnel I/O
		return;
	}

	protected void endPacketIfNeeded() {
		// Nothing to do except for Funnel I/O
		return;
	}

	protected void queryVersion() {
		writeByte(ARD_REPORT_VERSION);
	}

	abstract void writeByte(int data);

}