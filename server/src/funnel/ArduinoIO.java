/**
 * A hardware abstraction layer for the Arduino I/O board with Firmata v1.0 firmware
 * 
 * References:
 * Erik Sjödin's implementation for ActionScript 3
 * http://www.eriksjodin.net/blog/index.php/arduino-for-flash/
 * 
 * @see http://www.arduino.cc/playground/Interfacing/Firmata
 * @see http://www.arduino.cc/playground/Interfacing/FirmataProtocolDetails
 * @see http://at.or.at/hans/pd/objects.html
 */
package funnel;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Arrays;
import java.util.Enumeration;
import java.util.Vector;

import com.illposed.osc.OSCBundle;
import com.illposed.osc.OSCMessage;

import gnu.io.CommPortIdentifier;
import gnu.io.SerialPort;
import gnu.io.SerialPortEvent;
import gnu.io.SerialPortEventListener;

/**
 * @author kotobuki
 * 
 */
public class ArduinoIO extends IOModule implements SerialPortEventListener {
	private static final int ARD_TOTAL_ANALOG_PINS = 6;
	private static final int ARD_TOTAL_DIGITAL_PINS = 14;
	private static final int ARD_TOTAL_PINS = ARD_TOTAL_ANALOG_PINS
			+ ARD_TOTAL_DIGITAL_PINS;
	private static final int ARD_MAX_DATA_BYTES = 3;

	private static final int ARD_ANALOG_MESSAGE = 0xE0;
	private static final int ARD_DIGITAL_MESSAGE = 0x90;
	private static final int ARD_REPORT_ANALOG_PIN = 0xC0;
	private static final int ARD_REPORT_DIGITAL_PORTS = 0xD0;
	private static final int ARD_SET_DIGITAL_PIN_MODE = 0xF4;
	private static final int ARD_REPORT_VERSION = 0xF9;
	private static final int ARD_SYSTEM_RESET = 0xFF;

	private static final int ARD_PIN_MODE_IN = 0x00;
	private static final int ARD_PIN_MODE_OUT = 0x01;
	private static final int ARD_PIN_MODE_PWM = 0x02;
	private static final int ARD_PIN_MODE_AIN = 0x03;

	private static final int[] aoutAvailablePorts = new int[] { 9, 11, 12, 15,
			16, 17 };

	private SerialPort port;
	private InputStream input;
	private OutputStream output;

	private final int rate = 57600;
	private final int parity = SerialPort.PARITY_NONE;
	private final int databits = 8;
	private final int stopbits = SerialPort.STOPBITS_1;

	// data processing variables
	private int bytesToReceive = 0;
	private int executeMultiByteCommand = 0;
	private int multiByteChannel = 0;

	// data
	private int[] storedInputData = new int[ARD_MAX_DATA_BYTES];
	private float[] analogData = new float[ARD_TOTAL_ANALOG_PINS];
	private float[] digitalData = new float[ARD_TOTAL_DIGITAL_PINS];
	private int[] pinMode = new int[ARD_TOTAL_PINS];
	private int[] firmwareVersion = new int[ARD_MAX_DATA_BYTES];
	private int digitalPins = 0;

	private funnel.PortRange analogPortRange;
	private funnel.PortRange digitalPortRange;
	private Vector dinPortChunks;

	private final Float FLOAT_ZERO = new Float(0.0f);

	private funnel.BlockingQueue firmwareVersionQueue;

	public ArduinoIO(FunnelServer server, String serialPortName) {
		this.parent = server;
		parent.printMessage(Messages.getString("IOModule.Starting")); //$NON-NLS-1$

		analogPortRange = new funnel.PortRange();
		analogPortRange.setRange(0, 5); // 6 ports
		digitalPortRange = new funnel.PortRange();
		digitalPortRange.setRange(6, 19); // 14 ports
		dinPortChunks = new Vector();
		firmwareVersionQueue = new funnel.BlockingQueue();

		try {
			Enumeration portList = CommPortIdentifier.getPortIdentifiers();

			while (portList.hasMoreElements()) {
				CommPortIdentifier portId = (CommPortIdentifier) portList
						.nextElement();

				if (portId.getPortType() == CommPortIdentifier.PORT_SERIAL) {
					if (portId.getName().equals(serialPortName)) {
						port = (SerialPort) portId.open("serial arduino", 2000); //$NON-NLS-1$
						input = port.getInputStream();
						output = port.getOutputStream();
						port.setSerialPortParams(rate, databits, stopbits,
								parity);
						port.addEventListener(this);
						port.notifyOnDataAvailable(true);

						writeByte(ARD_REPORT_VERSION);
						firmwareVersionQueue.pop(15000);
						firmwareVersionQueue.clear();

						parent.printMessage(Messages
								.getString("IOModule.Started") //$NON-NLS-1$
								+ serialPortName);
					}
				}
			}
			if (port == null)
				printMessage(Messages.getString("IOModule.PortNotFoundError")); //$NON-NLS-1$

		} catch (Exception e) {
			printMessage(Messages.getString("IOModule.InsideSerialError")); //$NON-NLS-1$
			e.printStackTrace();
			port = null;
			input = null;
			output = null;
		}
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
		int totalPortCounts = analogPortRange.getCounts()
				+ digitalPortRange.getCounts();

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
			if (digitalPortRange.contains(port)) {
				results[2 + i] = new Float(digitalData[port
						- digitalPortRange.getMin()]);
			} else if (analogPortRange.contains(port)) {
				results[2 + i] = new Float(analogData[port
						- analogPortRange.getMin()]);
			}
		}
		return results;
	}

	public OSCBundle getAllInputsAsBundle() {
		if (!isPolling) {
			return null;
		}

		OSCBundle bundle = new OSCBundle();

		Object ainArguments[] = new Object[2 + analogPortRange.getCounts()];
		ainArguments[0] = new Integer(0);
		ainArguments[1] = new Integer(analogPortRange.getMin());
		for (int i = 0; i < analogPortRange.getCounts(); i++) {
			ainArguments[2 + i] = new Float(analogData[i]);
		}
		bundle.addPacket(new OSCMessage("/in", ainArguments)); //$NON-NLS-1$

		for (int j = 0; j < dinPortChunks.size(); j++) {
			PortRange range = (PortRange) dinPortChunks.get(j);
			Object dinArguments[] = new Object[2 + range.getCounts()];
			dinArguments[0] = new Integer(0);
			dinArguments[1] = new Integer(range.getMin());
			int offset = range.getMin() - digitalPortRange.getMin();
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

		// Set all outputs 0
		// This part will be replaced if Firmata supports s REAL reboot function
		for (int i = digitalPortRange.getMin(); i <= digitalPortRange.getMax(); i++) {
			if (pinMode[i] == ARD_PIN_MODE_OUT) {
				digitalWrite(i, 0);
			} else if (pinMode[i] == ARD_PIN_MODE_PWM) {
				analogWrite(i, 0.0f);
			}
		}

		printMessage(Messages.getString("IOModule.Rebooting")); //$NON-NLS-1$
		writeByte(ARD_SYSTEM_RESET);

		// This is dummy, since the system reset function is not implemented in
		// the Firmata firmware 0.31
		sleep(500);

		writeByte(ARD_REPORT_VERSION);
		firmwareVersionQueue.pop(15000);
		printMessage(Messages.getString("IOModule.Rebooted")); //$NON-NLS-1$
	}

	synchronized public void serialEvent(SerialPortEvent serialEvent) {
		if (serialEvent.getEventType() == SerialPortEvent.DATA_AVAILABLE) {
			try {
				while (input.available() > 0) {
					int inputData = input.read();
					int command = 0;

					if (inputData < 0)
						inputData = 256 + inputData;

					// we have data
					if (bytesToReceive > 0 && inputData < 128) {
						bytesToReceive--;

						storedInputData[bytesToReceive] = inputData;

						if ((executeMultiByteCommand != 0)
								&& (bytesToReceive == 0)) {
							// we got everything
							switch (executeMultiByteCommand) {
							case ARD_DIGITAL_MESSAGE:
								processDigitalBytes(storedInputData[1],
										storedInputData[0]); // (LSB, MSB)
								break;
							case ARD_REPORT_VERSION: // Report version
								firmwareVersion[0] = storedInputData[0]; // major
								firmwareVersion[1] = storedInputData[1]; // minor
								firmwareVersion[2] = 0;
								printMessage(Messages
										.getString("IOModule.FirmwareVesrion") //$NON-NLS-1$
										+ firmwareVersion[0] + "." //$NON-NLS-1$
										+ firmwareVersion[1] + "." //$NON-NLS-1$
										+ firmwareVersion[2]);
								firmwareVersionQueue.push(new String(""));
								break;
							case ARD_ANALOG_MESSAGE:
								analogData[multiByteChannel] = (float) ((storedInputData[0] << 7) | storedInputData[1]) / 1023.0f;
								break;
							}

						}
					}

					// we have a command
					else {

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
			} catch (IOException e) {

			}

		}
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
		dinPortChunks.clear();

		if (config.length != (ARD_TOTAL_ANALOG_PINS + ARD_TOTAL_DIGITAL_PINS)) {
			throw new IllegalArgumentException(
					"The number of pins does not match to that of the Arduino I/O module"); //$NON-NLS-1$
		}
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
			if (analogPortRange.contains(i)) {
				if (!PORT_AIN.equals(config[i])) {
					throw new IllegalArgumentException(
							"Only AIN is available on the following port: " + i);
				}
				pinMode[i] = ARD_PIN_MODE_AIN;
			} else if (digitalPortRange.contains(i)) {
				if (PORT_AOUT.equals(config[i])) {
					if (Arrays.binarySearch(aoutAvailablePorts, i) < 0) {
						throw new IllegalArgumentException(
								"AOUT is not available on the following port: "
										+ i);
					}
					setPinMode(i - digitalPortRange.getMin(), ARD_PIN_MODE_PWM);
					pinMode[i] = ARD_PIN_MODE_PWM;
				} else if (PORT_DIN.equals(config[i])) {
					setPinMode(i - digitalPortRange.getMin(), ARD_PIN_MODE_IN);
					pinMode[i] = ARD_PIN_MODE_IN;
				} else if (PORT_DOUT.equals(config[i])) {
					setPinMode(i - digitalPortRange.getMin(), ARD_PIN_MODE_OUT);
					pinMode[i] = ARD_PIN_MODE_OUT;
				} else {
					throw new IllegalArgumentException(
							"A wrong port mode is specified for the following port: "
									+ i);
				}
			}
		}

		boolean wasNotInput = true;
		int from = 0;
		int to = 0;
		for (int i = digitalPortRange.getMin(); i <= digitalPortRange.getMax(); i++) {
			if (wasNotInput && pinMode[i] == ARD_PIN_MODE_IN) {
				from = i;
				wasNotInput = false;
			} else if (!wasNotInput && pinMode[i] != ARD_PIN_MODE_IN) {
				to = i - 1;
				PortRange range = new PortRange();
				range.setRange(from, to);
				dinPortChunks.add(range);
				wasNotInput = true;
			}
		}

		// process the last block
		if (pinMode[digitalPortRange.getMax()] == ARD_PIN_MODE_IN) {
			to = digitalPortRange.getMax();
			PortRange range = new PortRange();
			range.setRange(from, to);
			dinPortChunks.add(range);
		}

		if (dinPortChunks != null) {
			for (int i = 0; i < dinPortChunks.size(); i++) {
				PortRange range = (PortRange) dinPortChunks.get(i);
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
		// printMessage("arguments: " + arguments[0] + ", " + arguments[1]);
		// //$NON-NLS-1$ //$NON-NLS-2$
		int start = ((Integer) arguments[1]).intValue();
		for (int i = 0; i < (arguments.length - 2); i++) {
			int port = start + i;
			int index = 2 + i;
			if (digitalPortRange.contains(port)) {
				// converts from global pin number to local pin number
				// e.g. global pin number 6 means local pin number 0
				int pin = port - digitalPortRange.getMin();

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

		for (int pin = 0; pin < 8; pin++) {
			setAnalogPinReporting(pin, 1);
		}
		enableDigitalPinReporting();
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
		for (int pin = 0; pin < 8; pin++) {
			setAnalogPinReporting(pin, 0);
		}
		disableDigitalPinReporting();
	}

	private void processDigitalBytes(int pin0_6, int pin7_13) {
		int mask;
		int twoBytesForPorts;

		// this should be converted to use PORTs (?)
		twoBytesForPorts = pin0_6 + (pin7_13 << 7);

		// ignore Rx,Tx pins (0 and 1)
		for (int i = 2; i < ARD_TOTAL_DIGITAL_PINS; ++i) {
			mask = 1 << i;
			digitalData[i] = (float) ((twoBytesForPorts & mask) >> i);
		}
	}

	private void setAnalogPinReporting(int pin, int mode) {
		writeByte(ARD_REPORT_ANALOG_PIN + pin);
		writeByte(mode);
	}

	private void enableDigitalPinReporting() {
		writeByte(ARD_REPORT_DIGITAL_PORTS);
		writeByte(1);
	}

	private void disableDigitalPinReporting() {
		writeByte(ARD_REPORT_DIGITAL_PORTS);
		writeByte(0);
	}

	private void setPinMode(int pin, int mode) {
		writeByte(ARD_SET_DIGITAL_PIN_MODE);
		writeByte(pin);
		writeByte(mode);
	}

	private void digitalWrite(int pin, int mode) {
		int bitMask = 1 << pin;

		if (mode == 1) {
			digitalPins |= bitMask;
		} else if (mode == 0) {
			digitalPins &= ~bitMask;
		}

		writeByte(ARD_DIGITAL_MESSAGE);
		writeByte(digitalPins % 128); // Tx pins 0-6
		writeByte(digitalPins >> 7); // Tx pins 7-13
	}

	private void analogWrite(int pin, float value) {
		int intValue = Math.round(value * 255.0f);
		intValue = (intValue < 0) ? 0 : intValue;
		intValue = (intValue > 255) ? 255 : intValue;

		writeByte(ARD_ANALOG_MESSAGE + pin);
		writeByte(intValue % 128);
		writeByte(intValue >> 7);
	}

	private void writeByte(int data) {
		try {
			output.write((byte) data);
			output.flush();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}
