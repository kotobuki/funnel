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
import java.util.Enumeration;
import java.util.concurrent.LinkedBlockingQueue;

import com.illposed.osc.OSCBundle;
import com.illposed.osc.OSCMessage;
import com.illposed.osc.OSCPacket;

import gnu.io.CommPortIdentifier;
import gnu.io.SerialPort;
import gnu.io.SerialPortEvent;
import gnu.io.SerialPortEventListener;

/**
 * @author kotobuki
 * 
 */
public class ArduinoIO extends IOModule implements SerialPortEventListener {
	private static final int ARD_TOTAL_ANALOG_PINS = 8;
	private static final int ARD_TOTAL_DIGITAL_PINS = 14;
	private static final int ARD_MAX_DATA_BYTES = 2;

	private static final int ARD_ANALOG_MESSAGE = 0xE0;
	private static final int ARD_DIGITAL_MESSAGE = 0x90;
	private static final int ARD_REPORT_ANALOG_PIN = 0xC0;
	private static final int ARD_REPORT_DIGITAL_PORTS = 0xD0;
	private static final int ARD_SET_DIGITAL_PIN_MODE = 0xF4;
	private static final int ARD_REPORT_VERSION = 0xF9;
	private static final int ARD_SYSTEM_RESET = 0xFF;

	private static final int ARD_PIN_MODE_IN = 0x00;
	private static final int ARD_PIN_MODE_OUT = 0x01;

	private SerialPort port;
	private InputStream input;
	private OutputStream output;

	private final int rate = 115200;
	private final int parity = SerialPort.PARITY_NONE;
	private final int databits = 8;
	private final int stopbits = SerialPort.STOPBITS_1;

	// data processing variables
	private int waitForData = 0;
	private int executeMultiByteCommand = 0;
	private int multiByteChannel = 0;

	// data
	private int[] storedInputData = new int[ARD_MAX_DATA_BYTES];;
	private float[] analogData = new float[ARD_TOTAL_ANALOG_PINS];
	private float[] digitalData = new float[ARD_TOTAL_DIGITAL_PINS];
	private int[] digitalPinMode = new int[ARD_TOTAL_DIGITAL_PINS];
	private int[] firmwareVersion = new int[ARD_MAX_DATA_BYTES];
	private int digitalPins = 0;

	private funnel.PortRange analogPortRange;
	private funnel.PortRange digitalPortRange;

	private final Float FLOAT_ZERO = 0.0f;

	public ArduinoIO(FunnelServer server, String serialPortName) {
		this.parent = server;
		parent.printMessage("Starting the Gainer I/O module...");

		analogPortRange = new funnel.PortRange();
		analogPortRange.setRange(0, 7); // 8 ports
		digitalPortRange = new funnel.PortRange();
		digitalPortRange.setRange(8, 21); // 14 ports

		try {
			Enumeration portList = CommPortIdentifier.getPortIdentifiers();

			while (portList.hasMoreElements()) {
				CommPortIdentifier portId = (CommPortIdentifier) portList
						.nextElement();

				if (portId.getPortType() == CommPortIdentifier.PORT_SERIAL) {
					if (portId.getName().equals(serialPortName)) {
						port = (SerialPort) portId.open("serial arduino", 2000);
						input = port.getInputStream();
						output = port.getOutputStream();
						port.setSerialPortParams(rate, databits, stopbits,
								parity);
						port.addEventListener(this);
						port.notifyOnDataAvailable(true);

						parent.printMessage("Arduino started on port "
								+ serialPortName);
					}
				}
			}
			if (port == null)
				printMessage("specified port was not found...");

		} catch (Exception e) {
			printMessage("connection error inside Serial. closing serialport...");
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
	@Override
	public void dispose() {
		port.removeEventListener();
		printMessage("Disposing communication with the Arduino board...");
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
	@Override
	public Object[] getInputs(String address, Object[] arguments)
			throws IllegalArgumentException {
		int from = 0;
		int counts = 0;
		int totalPortCounts = analogPortRange.getCounts()
				+ digitalPortRange.getCounts();

		if (address.equals("/in")) {
			from = (Integer) arguments[0];
			counts = (Integer) arguments[1];
		} else if (address.equals("/in/*")) {
			from = 0;
			counts = totalPortCounts;
		}

		if ((from + counts) > totalPortCounts) {
			counts = totalPortCounts - from;
		}

		if ((from >= totalPortCounts) || (counts <= 0)) {
			throw new IllegalArgumentException("");
		}

		Object[] results = new Object[1 + counts];
		results[0] = new Integer(from);
		for (int i = 0; i < counts; i++) {
			int port = from + i;
			if (digitalPortRange.contains(port)) {
				results[1 + i] = new Float(digitalData[port
						- digitalPortRange.getMin()]);
			} else if (analogPortRange.contains(port)) {
				results[1 + i] = new Float(analogData[port
						- analogPortRange.getMin()]);
			}
		}
		return results;
	}

	public OSCBundle getAllInputsAsBundle() {
		OSCBundle bundle = new OSCBundle();

		Object ainArguments[] = new Object[1 + analogPortRange.getCounts()];
		ainArguments[0] = new Integer(analogPortRange.getMin());
		for (int i = 0; i < analogPortRange.getCounts(); i++) {
			ainArguments[1 + i] = new Float(analogData[i]);
		}
		bundle.addPacket(new OSCMessage("/in", ainArguments));

		Object dinArguments[] = new Object[1 + digitalPortRange.getCounts()];
		dinArguments[0] = new Integer(digitalPortRange.getMin());
		for (int i = 0; i < digitalPortRange.getCounts(); i++) {
			dinArguments[1 + i] = new Float(digitalData[i]);
		}
		bundle.addPacket(new OSCMessage("/in", dinArguments));

		return bundle;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see funnel.IOModule#reboot()
	 */
	@Override
	public void reboot() {
		if (port == null) {
			return;
		}
		printMessage("Rebooting the Arduino I/O board...");
		writeByte(ARD_SYSTEM_RESET);

		// This is dummy, since the system reset function is not implemented in
		// the Firmata firmware v1.0
		sleep(1000);

		writeByte(ARD_REPORT_VERSION);
		printMessage("...finished!");
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
					if (waitForData > 0 && inputData < 128) {
						waitForData--;

						storedInputData[waitForData] = inputData;

						if ((executeMultiByteCommand != 0)
								&& (waitForData == 0)) {
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
								printMessage("firmware version: "
										+ firmwareVersion[0] + "."
										+ firmwareVersion[1] + "."
										+ firmwareVersion[2]);
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
							waitForData = 2; // 3 bytes needed
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
	@Override
	public void setConfiguration(Object[] arguments) {
		if (arguments.length != (ARD_TOTAL_ANALOG_PINS + ARD_TOTAL_DIGITAL_PINS)) {
			throw new IllegalArgumentException(
					"The number of pins does not match to that of the Arduino I/O module");
		}
		for (int i = 0; i < arguments.length; i++) {
			if (analogPortRange.contains(i)) {
				if (arguments[i] != null && arguments[i] instanceof Integer) {
					if (!PORT_AIN.equals(arguments[i])) {
						throw new IllegalArgumentException("Wrong port mode ("
								+ i + ")");
					}
				} else {
					throw new IllegalArgumentException("Wrong port mode (" + i
							+ ")");
				}
			} else if (digitalPortRange.contains(i)) {
				if (arguments[i] != null && arguments[i] instanceof Integer) {
					int pinMode = PORT_DIN.equals(arguments[i]) ? ARD_PIN_MODE_IN
							: ARD_PIN_MODE_OUT;
					setPinMode(i - digitalPortRange.getMin(), pinMode);
					digitalPinMode[i - digitalPortRange.getMin()] = pinMode;
				} else {
					throw new IllegalArgumentException("Wrong port mode (" + i
							+ ")");
				}
			}
		}
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see funnel.IOModule#setOutput(java.lang.Object[])
	 */
	@Override
	public void setOutput(Object[] arguments) {
		printMessage("arguments: " + arguments[0] + ", " + arguments[1]);
		int start = (Integer) arguments[0];
		for (int i = 0; i < (arguments.length - 1); i++) {
			int port = start + i;
			int index = 1 + i;
			if (digitalPortRange.contains(port)) {
				if (arguments[index] != null
						&& arguments[index] instanceof Float) {
					if (FLOAT_ZERO.equals(arguments[index])) {
						writeDigitalPin(port - digitalPortRange.getMin(), 0);
					} else {
						writeDigitalPin(port - digitalPortRange.getMin(), 1);
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
	@Override
	public void setPolling(Object[] arguments) {
		if (arguments[0] instanceof Integer) {
			if (new Integer(1).equals(arguments[0])) {
				startPolling();
			} else {
				stopPolling();
			}
		} else {
			throw new IllegalArgumentException(
					"The first argument of /polling is not an integer value");
		}
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see funnel.IOModule#stopPolling()
	 */
	@Override
	public void startPolling() {
		if (port == null) {
			return;
		}

		for (int pin = 0; pin < 8; pin++) {
			setAnalogPinReporting(pin, 1);
		}
		enableDigitalPinReporting();
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see funnel.IOModule#stopPolling()
	 */
	@Override
	public void stopPolling() {
		if (port == null) {
			return;
		}

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

	private void writeDigitalPin(int pin, int mode) {
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

	private void writeAnalogPin(int pin, int value) {
		writeByte(ARD_ANALOG_MESSAGE + pin);
		writeByte(value >> 7);
		writeByte(value % 128);
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
