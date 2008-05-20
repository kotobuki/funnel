package funnel;

import java.io.InputStream;
import java.io.OutputStream;
import java.util.Vector;

import gnu.io.SerialPort;

public abstract class FirmataIO extends IOModule {

	protected static final int ARD_TOTAL_ANALOG_PINS = 6;
	protected static final int ARD_TOTAL_DIGITAL_PINS = 14;
	private static final int ARD_TOTAL_PINS = ARD_TOTAL_ANALOG_PINS
				+ ARD_TOTAL_DIGITAL_PINS;
	private static final int ARD_MAX_DATA_BYTES = 3;
	protected static final int ARD_ANALOG_MESSAGE = 0xE0;
	protected static final int ARD_DIGITAL_MESSAGE = 0x90;
	private static final int ARD_REPORT_ANALOG_PIN = 0xC0;
	private static final int ARD_REPORT_DIGITAL_PORTS = 0xD0;
	private static final int ARD_SET_DIGITAL_PIN_MODE = 0xF4;
	protected static final int ARD_REPORT_VERSION = 0xF9;
	protected static final int ARD_SYSTEM_RESET = 0xFF;
	protected static final int ARD_PIN_MODE_IN = 0x00;
	protected static final int ARD_PIN_MODE_OUT = 0x01;
	protected static final int ARD_PIN_MODE_PWM = 0x02;
	protected static final int ARD_PIN_MODE_AIN = 0x03;
	protected static final int[] aoutAvailablePorts = new int[] { 9, 11, 12, 15,
				16, 17 };
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
	protected float[] analogData = new float[ARD_TOTAL_ANALOG_PINS];
	protected float[] digitalData = new float[ARD_TOTAL_DIGITAL_PINS];
	protected int[] pinMode = new int[ARD_TOTAL_PINS];
	protected int[] firmwareVersion = new int[ARD_MAX_DATA_BYTES];
	private int digitalPins = 0;
	protected funnel.PortRange analogPortRange;
	protected funnel.PortRange digitalPortRange;
	protected Vector dinPortChunks;
	protected final Float FLOAT_ZERO = new Float(0.0f);
	protected funnel.BlockingQueue firmwareVersionQueue;

	public FirmataIO() {
		super();
	}

	protected void processInput(int inputData) {
		int command = 0;

		if (inputData < 0)
			inputData = 256 + inputData;

		// we have data
		if (bytesToReceive > 0 && inputData < 128) {
			bytesToReceive--;

			storedInputData[bytesToReceive] = inputData;

			if ((executeMultiByteCommand != 0) && (bytesToReceive == 0)) {
				// we got everything
				switch (executeMultiByteCommand) {
				case ARD_DIGITAL_MESSAGE:
					processDigitalBytes(storedInputData[1], storedInputData[0]); // (LSB,
					// MSB)
					break;
				case ARD_REPORT_VERSION: // Report version
					firmwareVersion[0] = storedInputData[0]; // major
					firmwareVersion[1] = storedInputData[1]; // minor
					firmwareVersion[2] = 0;
					printMessage(Messages.getString("IOModule.FirmwareVesrion") //$NON-NLS-1$
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

	protected void processDigitalBytes(int pin0_6, int pin7_13) {
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

	protected void setAnalogPinReporting(int pin, int mode) {
		writeByte(ARD_REPORT_ANALOG_PIN + pin);
		writeByte(mode);
	}

	protected void enableDigitalPinReporting() {
		writeByte(ARD_REPORT_DIGITAL_PORTS);
		writeByte(1);
	}

	protected void disableDigitalPinReporting() {
		writeByte(ARD_REPORT_DIGITAL_PORTS);
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
			digitalPins |= bitMask;
		} else if (mode == 0) {
			digitalPins &= ~bitMask;
		}
	
		writeByte(ARD_DIGITAL_MESSAGE);
		writeByte(digitalPins % 128); // Tx pins 0-6
		writeByte(digitalPins >> 7); // Tx pins 7-13
	}

	protected void analogWrite(int pin, float value) {
		int intValue = Math.round(value * 255.0f);
		intValue = (intValue < 0) ? 0 : intValue;
		intValue = (intValue > 255) ? 255 : intValue;
	
		writeByte(ARD_ANALOG_MESSAGE + pin);
		writeByte(intValue % 128);
		writeByte(intValue >> 7);
	}

	abstract void writeByte(int data);

}