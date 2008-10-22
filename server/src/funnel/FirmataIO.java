package funnel;

import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Enumeration;
import java.util.TooManyListenersException;
import java.util.Vector;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;

import com.illposed.osc.OSCMessage;

import gnu.io.CommPortIdentifier;
import gnu.io.SerialPort;
import gnu.io.SerialPortEventListener;

public abstract class FirmataIO extends IOModule implements SerialPortEventListener {

	protected static final int MAX_NODES = 65535;

	private static final int ARD_MAX_DATA_BYTES = 3;
	private static final int ARD_ANALOG_MESSAGE = 0xE0;
	private static final int ARD_DIGITAL_MESSAGE = 0x90;
	private static final int ARD_REPORT_ANALOG_PIN = 0xC0;
	private static final int ARD_REPORT_DIGITAL_PORTS = 0xD0;
	private static final int ARD_SET_DIGITAL_PIN_MODE = 0xF4;
	protected static final int ARD_REPORT_VERSION = 0xF9;
	protected static final int ARD_SYSTEM_RESET = 0xFF;
	protected static final int ARD_SYSEX_START = 0xF0;
	protected static final int ARD_SYSEX_END = 0xF7;
	protected static final int ARD_PIN_MODE_IN = 0x00;
	protected static final int ARD_PIN_MODE_OUT = 0x01;
	protected static final int ARD_PIN_MODE_AIN = 0x02;
	protected static final int ARD_PIN_MODE_PWM = 0x03;
	protected static final int ARD_PIN_MODE_SERVO = 0x04;

	protected int totalAnalogPins = 8;
	protected int totalDigitalPins = 22;
	protected int[] pwmCapablePins = null;
	protected SerialPort port;
	protected InputStream input;
	protected OutputStream output;
	protected final int rate = 57600;
	protected final int parity = SerialPort.PARITY_NONE;
	protected final int databits = 8;
	protected final int stopbits = SerialPort.STOPBITS_1;

	protected int[] bytesToReceive = new int[MAX_NODES];
	protected int[] executeMultiByteCommand = new int[MAX_NODES];
	protected int[] multiByteChannel = new int[MAX_NODES];
	protected int[][] storedInputData = new int[MAX_NODES][ARD_MAX_DATA_BYTES];

	protected float[][] digitalData = null;
	protected boolean[] digitalPinUpdated = null;
	protected int[] pinMode;
	protected int[] firmwareVersion = new int[ARD_MAX_DATA_BYTES];
	private int stateOfDigitalPins = 0x0000;
	protected funnel.PortRange analogPinRange;
	protected funnel.PortRange digitalPinRange;
	protected Vector<PortRange> dinPinChunks;
	protected int rearmostAnalogInputPin = -1;
	protected BlockingQueue<String> firmwareVersionQueue;
	protected ArrayList<ArrayList<Integer>> sysExDataList;

	public FirmataIO(int analogPins, int digitalPins, int[] pwmPins) {
		super();

		totalAnalogPins = analogPins;
		totalDigitalPins = digitalPins;
		pwmCapablePins = (int[]) pwmPins.clone();
		pinMode = new int[totalDigitalPins];

		digitalData = new float[MAX_NODES][totalDigitalPins];
		for (int i = 0; i < MAX_NODES; i++) {
			for (int j = 0; j < totalDigitalPins; j++) {
				digitalData[i][j] = -1;
			}
		}

		digitalPinUpdated = new boolean[totalDigitalPins];
		firmwareVersionQueue = new LinkedBlockingQueue<String>(1);
		sysExDataList = new ArrayList<ArrayList<Integer>>(MAX_NODES);
		for (int i = 0; i < MAX_NODES; i++) {
			sysExDataList.add(i, new ArrayList<Integer>(0));
		}

		digitalPinRange = new funnel.PortRange();
		digitalPinRange.setRange(0, totalDigitalPins - 1);
		dinPinChunks = new Vector<PortRange>();
		analogPinRange = new funnel.PortRange();
		analogPinRange.setRange(totalDigitalPins - totalAnalogPins, totalDigitalPins - 1);
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
	public Object[] getInputs(String address, Object[] arguments) throws IllegalArgumentException {
		int moduleId = 0;
		int from = 0;
		int counts = 0;
		int totalPinCounts = analogPinRange.getCounts() + digitalPinRange.getCounts();

		if (address.equals("/in")) { //$NON-NLS-1$
			moduleId = ((Integer) arguments[0]).intValue();
			from = ((Integer) arguments[1]).intValue();
			counts = ((Integer) arguments[2]).intValue();
		} else if (address.equals("/in/*")) { //$NON-NLS-1$
			moduleId = ((Integer) arguments[0]).intValue();
			from = 0;
			counts = totalPinCounts;
		}

		if ((from + counts) > totalPinCounts) {
			counts = totalPinCounts - from;
		}

		if ((from >= totalPinCounts) || (counts <= 0)) {
			throw new IllegalArgumentException(""); //$NON-NLS-1$
		}

		Object[] results = new Object[2 + counts];
		results[0] = new Integer(moduleId);
		results[1] = new Integer(from);
		for (int i = 0; i < counts; i++) {
			int pin = from + i;
			if (digitalPinRange.contains(pin)) {
				results[2 + i] = new Float(digitalData[moduleId][pin]);
			}
		}
		return results;
	}

	public void notifyUpdate(int source, int from, int counts) {
		Object[] results = new Object[2 + counts];
		results[0] = new Integer(source);
		results[1] = new Integer(from);
		for (int i = 0; i < counts; i++) {
			int pin = from + i;
			if (digitalPinRange.contains(pin)) {
				results[2 + i] = new Float(digitalData[source][pin]);
			}
		}

		OSCMessage message = new OSCMessage("/in", results);
		parent.getCommandPortServer().sendMessageToClients(message);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see funnel.IOModule#reboot()
	 */
	abstract public void reboot();

	/*
	 * (non-Javadoc)
	 * 
	 * @see funnel.IOModule#setConfiguration(java.lang.Object[])
	 */
	public void setConfiguration(Object[] arguments) {
		boolean wasPollingEnabled = isPolling;
		if (isPolling) {
			stopPolling();
			sleep(100);
		}

		int moduleId = ((Integer) arguments[0]).intValue();

		if ((moduleId != 0) && (moduleId != 0xFFFF)) {
			// Accept configuration command to a 0th module or broadcast only
			for (int j = 0; j < dinPinChunks.size(); j++) {
				PortRange range = dinPinChunks.get(j);
				notifyUpdate(moduleId, range.getMin(), range.getCounts());
			}
			return;
		}

		Object[] config = new Object[arguments.length - 1];
		System.arraycopy(arguments, 1, config, 0, arguments.length - 1);

		dinPinChunks.clear();
		rearmostAnalogInputPin = -1;

		if (config.length != totalDigitalPins) {
			throw new IllegalArgumentException(
					"The number of pins does not match to that of the Arduino I/O module"); //$NON-NLS-1$
		}

		beginPacketIfNeeded(moduleId);
		for (int i = 0; i < config.length; i++) {
			if (config[i] == null) {
				throw new IllegalArgumentException("Argument of the following pin is null: " + i);
			}
			if (!(config[i] instanceof Integer)) {
				throw new IllegalArgumentException(
						"Argument of the following pin is not an integer value: " + i);
			}
			if (digitalPinRange.contains(i)) {
				if (PORT_AIN.equals(config[i])) {
					if (!analogPinRange.contains(i)) {
						throw new IllegalArgumentException(
								"AIN is not available on the following pin: " + i);
					}
					setPinMode(i, ARD_PIN_MODE_IN);
					pinMode[i] = ARD_PIN_MODE_AIN;
					rearmostAnalogInputPin = i - analogPinRange.getMin();
				} else if (PORT_AOUT.equals(config[i])) {
					if (Arrays.binarySearch(pwmCapablePins, i) < 0) {
						throw new IllegalArgumentException(
								"PWM is not available on the following pin: " + i);
					}
					setPinMode(i, ARD_PIN_MODE_PWM);
					pinMode[i] = ARD_PIN_MODE_PWM;
				} else if (PORT_DIN.equals(config[i])) {
					setPinMode(i, ARD_PIN_MODE_IN);
					pinMode[i] = ARD_PIN_MODE_IN;
				} else if (PORT_DOUT.equals(config[i])) {
					setPinMode(i, ARD_PIN_MODE_OUT);
					pinMode[i] = ARD_PIN_MODE_OUT;
				} else {
					throw new IllegalArgumentException(
							"A wrong pin mode is specified for the following pin: " + i);
				}
			} else {
				throw new IllegalArgumentException("The following pin number is out of range: " + i);
			}
		}
		endPacketIfNeeded();

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

		// if (dinPinChunks != null) {
		// for (int i = 0; i < dinPinChunks.size(); i++) {
		// PortRange range = dinPinChunks.get(i);
		// printMessage("digital inputs: [" + range.getMin() + ".." +
		// range.getMax() + "]");
		// }
		// }

		for (int j = 0; j < dinPinChunks.size(); j++) {
			PortRange range = dinPinChunks.get(j);
			notifyUpdate(moduleId, range.getMin(), range.getCounts());
		}

		if (wasPollingEnabled) {
			startPolling();
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
			int pin = start + i;
			int index = 2 + i;
			if (digitalPinRange.contains(pin)) {
				// converts from global pin number to local pin number
				// e.g. global pin number 6 means local pin number 0
				int pinNumber = pin - digitalPinRange.getMin();

				if (arguments[index] != null && arguments[index] instanceof Float) {
					if (pinMode[pin] == ARD_PIN_MODE_OUT) {
						digitalWrite(pinNumber, FLOAT_ZERO.equals(arguments[index]) ? 0 : 1);
					} else if (pinMode[pin] == ARD_PIN_MODE_PWM) {
						analogWrite(pinNumber, ((Float) arguments[index]).floatValue());
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
			if (pinMode[pin + analogPinRange.getMin()] == ARD_PIN_MODE_AIN) {
				setAnalogPinReporting(pin, 1);
			}
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

	public void sendSystemExclusiveMessage(Object[] arguments) {
		int moduleId = ((Integer) arguments[0]).intValue();
		int command = ((Integer) arguments[1]).intValue();

		beginPacketIfNeeded(moduleId);
		writeByte(ARD_SYSEX_START);
		writeByte(command);
		for (int i = 2; i < arguments.length; i++) {
			int value = ((Integer) arguments[i]).intValue();
			writeByte(value & 0x7F); // LSB
			writeByte((value >> 7) & 0x7F); // MSB
		}
		writeByte(ARD_SYSEX_END);
		endPacketIfNeeded();
	}

	protected void begin(String serialPortName, int baudRate) {
		printMessage(Messages.getString("IOModule.Starting")); //$NON-NLS-1$

		try {
			Enumeration<?> portList = CommPortIdentifier.getPortIdentifiers();

			while (portList.hasMoreElements()) {
				CommPortIdentifier portId = (CommPortIdentifier) portList.nextElement();

				if (portId.getPortType() == CommPortIdentifier.PORT_SERIAL) {
					if (portId.getName().equals(serialPortName)) {
						port = (SerialPort) portId.open("serial firmata", 2000); //$NON-NLS-1$
						input = port.getInputStream();
						output = port.getOutputStream();
						if (baudRate > 0) {
							parent.printMessage("baudrate: " + baudRate);
							port.setSerialPortParams(baudRate, databits, stopbits, parity);
						} else {
							port.setSerialPortParams(rate, databits, stopbits, parity);
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

	protected void processInput(int source, int inputData) {
		int command = 0;

		if (inputData < 0)
			inputData = 256 + inputData;

		// We have data
		if (bytesToReceive[source] > 0 && inputData < 128) {
			bytesToReceive[source]--;

			storedInputData[source][bytesToReceive[source]] = inputData;
			if ((executeMultiByteCommand[source] != 0) && (bytesToReceive[source] == 0)) {
				// We got everything
				switch (executeMultiByteCommand[source]) {
				case ARD_DIGITAL_MESSAGE:
					processDigitalBytes(source, multiByteChannel[source],
							((storedInputData[source][0] << 7) | storedInputData[source][1]));
					break;
				case ARD_REPORT_VERSION: // Report version
					firmwareVersion[0] = storedInputData[source][0]; // minor
					firmwareVersion[1] = storedInputData[source][1]; // major
					printMessage("Firmata Protocol Version: " + firmwareVersion[1] + "."
							+ firmwareVersion[0]);
					firmwareVersionQueue.add(firmwareVersion[1] + "." + firmwareVersion[0]);
					break;
				case ARD_ANALOG_MESSAGE:
					digitalData[source][multiByteChannel[source] + analogPinRange.getMin()] = (float) ((storedInputData[source][0] << 7) | storedInputData[source][1]) / 1023.0f;
					if (multiByteChannel[source] == rearmostAnalogInputPin) {
						notifyUpdate(source, analogPinRange.getMin(), analogPinRange.getCounts());
					}
					break;
				}

			}
		} else if (bytesToReceive[source] < 0) {
			// We have SysEx command data
			if (inputData == ARD_SYSEX_END) {
				bytesToReceive[source] = 0;
				processSystemExclusiveData(source);
				sysExDataList.get(source).clear();
			} else {
				sysExDataList.get(source).add(inputData & 0x7F);
			}

		} else {
			// We have a command
			// remove channel info from command byte if less than
			// 0xF0
			if (inputData < 240) {
				command = inputData & 240;
				multiByteChannel[source] = inputData & 15;
			} else {
				// commands in the 0xF* range don't use channel data
				command = inputData;
			}

			switch (command) {
			case ARD_REPORT_VERSION:
			case ARD_DIGITAL_MESSAGE:
			case ARD_ANALOG_MESSAGE:
				bytesToReceive[source] = 2; // 3 bytes needed
				executeMultiByteCommand[source] = command;
				break;
			case ARD_SYSEX_START:
				sysExDataList.get(source).clear();
				bytesToReceive[source] = -1;
				executeMultiByteCommand[source] = command;
				break;
			}
		}
	}

	protected void processDigitalBytes(int source, int port, int value) {
		int mask;
		float lastValue = 0;

		for (int i = 0; i < totalDigitalPins; i++) {
			digitalPinUpdated[i] = false;
		}

		switch (port) {
		case 0: // D0 - D7
			// ignore Rx,Tx pins (0 and 1)
			for (int i = 2; i < 8; i++) {
				mask = 1 << i;
				lastValue = digitalData[source][i];
				digitalData[source][i] = ((value & mask) > 0) ? 1.0f : 0.0f;
				digitalPinUpdated[i] = (lastValue != digitalData[source][i]);
			}
			break;
		case 1: // D8 - D13
			for (int i = 8; i <= digitalPinRange.getMax(); i++) {
				mask = 1 << (i - 8);
				lastValue = digitalData[source][i];
				digitalData[source][i] = ((value & mask) > 0) ? 1.0f : 0.0f;
				digitalPinUpdated[i] = (lastValue != digitalData[source][i]);
			}
			break;
		case 2: // A0 - A7
			break;
		default:
			break;
		}

		for (int j = 0; j < dinPinChunks.size(); j++) {
			boolean needToReport = false;
			PortRange range = dinPinChunks.get(j);
			for (int pin = range.getMin(); pin <= range.getMax(); pin++) {
				if (digitalPinUpdated[pin]) {
					needToReport = true;
				}
			}
			if (needToReport) {
				notifyUpdate(source, range.getMin(), range.getCounts());
			}
		}
	}

	protected void processSystemExclusiveData(int source) {
		int counts = (sysExDataList.get(source).size() - 1) / 2;
		Object[] sysExMessage = new Object[2 + counts];
		int idx = 0;

		sysExMessage[0] = new Integer(source);
		sysExMessage[1] = sysExDataList.get(source).get(idx++);
		for (int i = 0; i < counts; i++) {
			int data = sysExDataList.get(source).get(idx++);
			data += sysExDataList.get(source).get(idx++) << 7;
			sysExMessage[2 + i] = data;
		}

		OSCMessage message = new OSCMessage("/sysex", sysExMessage);
		parent.getCommandPortServer().sendMessageToClients(message);
	}

	protected void setAnalogPinReporting(int pin, int mode) {
		writeByte(ARD_REPORT_ANALOG_PIN + pin);
		writeByte(mode);
	}

	protected void enableDigitalPinReporting() {
		boolean inputsAvailableInPort0 = false;
		boolean inputsAvailableInPort1 = false;

		if (dinPinChunks == null) {
			return;
		}

		for (int i = 0; i < dinPinChunks.size(); i++) {
			PortRange range = dinPinChunks.get(i);
			for (int pin = 0; pin < 8; pin++) {
				if (range.contains(pin)) {
					inputsAvailableInPort0 = true;
				}
			}
			for (int pin = 8; pin < 16; pin++) {
				if (range.contains(pin)) {
					inputsAvailableInPort1 = true;
				}
			}
		}

		writeByte(ARD_REPORT_DIGITAL_PORTS | 0x00);
		writeByte(inputsAvailableInPort0 ? 1 : 0);

		writeByte(ARD_REPORT_DIGITAL_PORTS | 0x01);
		writeByte(inputsAvailableInPort1 ? 1 : 0);
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