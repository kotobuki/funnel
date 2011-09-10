package funnel;

import gnu.io.CommPortIdentifier;
import gnu.io.SerialPort;
import gnu.io.SerialPortEventListener;

import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.TooManyListenersException;
import java.util.Vector;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;

import com.illposed.osc.OSCMessage;

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
	protected static final int ARD_PIN_MODE_I2C = 0x06;

	protected static final int CAPABILITY_QUERY = 0x6B;
	protected static final int CAPABILITY_RESPONSE = 0x6C;
	protected static final int SERVO_CONFIG = 0x70;
	protected static final int FIRMATA_STRING = 0x71;
	protected static final int SYSEX_I2C_REQUEST = 0x76;
	protected static final int SYSEX_I2C_REPLY = 0x77;
	protected static final int SYSEX_I2C_CONFIG = 0x78;
	protected static final int REPORT_FIRMWARE = 0x79;
	protected static final int SAMPLING_INTERVAL = 0x7A;
	protected static final int SYSEX_NON_REALTIME = 0x7E;
	protected static final int SYSEX_REALTIME = 0x7F;

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
	protected int[] protocolVersion = new int[ARD_MAX_DATA_BYTES];
	private int stateOfDigitalPins = 0;	// TODO: Should be an array of MAX_NODES
	protected Vector<PortRange> dinPinChunks;
	protected int rearmostAnalogInputPin = -1;
	protected BlockingQueue<String> firmwareVersionQueue;
	protected BlockingQueue<String> capabilitiesReceived;
	protected ArrayList<ArrayList<Integer>> sysExDataList;
	protected ArrayList<Integer> analogPins;
	protected ArrayList<Integer> digitalPins;
	protected ArrayList<Integer> pwmPins;
	protected ArrayList<Integer> servoPins;
	protected ArrayList<Integer> i2cPins;

	protected int analogPinOffset = 0;
	protected int maximumAnalogPinIndex = -1;

	private boolean hasBeenInitialized = false;
	
	public FirmataIO(int defaultAnalogPins, int defaultDigitalPins, int[] defaultPwmPins) {
		super();

		digitalPins = new ArrayList<Integer>();
		for (int i = 0; i < defaultDigitalPins; i++) {
			digitalPins.add(i);
		}

		analogPins = new ArrayList<Integer>();
		for (int i = defaultDigitalPins; i < (defaultDigitalPins + defaultAnalogPins); i++) {
			analogPins.add(i);
		}
		
		pwmPins = new ArrayList<Integer>();		
		for (int i = 0; i < defaultPwmPins.length; i++) {
			pwmPins.add(defaultPwmPins[i]);
		}

		servoPins = new ArrayList<Integer>();		
		for (int i = digitalPins.get(0); i < analogPins.get(0); i++) {
			servoPins.add(i);
		}

		i2cPins = new ArrayList<Integer>();
		i2cPins.add(18);	// SDA: A4/D18
		i2cPins.add(19);	// SCL: A5/D19

		dinPinChunks = new Vector<PortRange>();

		sysExDataList = new ArrayList<ArrayList<Integer>>(MAX_NODES);
		for (int i = 0; i < MAX_NODES; i++) {
			sysExDataList.add(i, new ArrayList<Integer>(0));
		}

		firmwareVersionQueue = new LinkedBlockingQueue<String>(1);
		capabilitiesReceived = new LinkedBlockingQueue<String>(1);
	}

	private void instantiatePinRelatedVariables() {
		if (hasBeenInitialized) {
			return;
		}

		maximumAnalogPinIndex = analogPins.size() - 1;

		pinMode = new int[digitalPins.size()];

		digitalData = new float[MAX_NODES][digitalPins.size()];
		for (int i = 0; i < MAX_NODES; i++) {
			for (int j = 0; j < digitalPins.size(); j++) {
				digitalData[i][j] = -1;
			}
		}

		digitalPinUpdated = new boolean[digitalPins.size()];

		hasBeenInitialized = true;
	}
	
	/*
	 * (non-Javadoc)
	 * 
	 * @see funnel.IOModule#dispose()
	 */
	public void dispose() {
		try {
			if (input != null) {
				input.close();
			}
			if (output != null) {
				output.close();
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		input = null;
		output = null;

		new Thread() {
			@Override
			public void run() {
				port.removeEventListener();
				port.close();
				port = null;
			}
		}.start();
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
		int totalPinCounts = digitalPins.size();

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
			if (digitalPins.indexOf(pin) >= 0) {
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
			if (digitalPins.indexOf(pin) >= 0) {
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

		if (config.length != digitalPins.size()) {
			printMessage("WARNING: The number of pins (" + config.length + ") does not match to that of the Arduino board (" + digitalPins.size() + ")");
//			throw new IllegalArgumentException("The number of pins does not match to that of the Arduino I/O module"); //$NON-NLS-1$
		}

		beginPacketIfNeeded(moduleId);
		for (int i = 0; i < config.length; i++) {
			if (config[i] == null) {
				printMessage("Argument of the following pin is null: " + i);
				throw new IllegalArgumentException("Argument of the following pin is null: " + i);
			}
			if (!(config[i] instanceof Integer)) {
				printMessage("Argument of the following pin is not an integer value: " + i);
				throw new IllegalArgumentException("Argument of the following pin is not an integer value: " + i);
			}
			if (digitalPins.indexOf(i) >= 0) {
				if (PIN_AIN.equals(config[i])) {
					if (analogPins.indexOf(i) < 0) {
						printMessage("Analog is not available for pin " + i);
						throw new IllegalArgumentException("Analog is not available for pin " + i);
					}
					setPinMode(i + analogPinOffset, ARD_PIN_MODE_AIN);
					pinMode[i] = ARD_PIN_MODE_AIN;
					if (pinFromDigitalToAnalog(i) <= maximumAnalogPinIndex) {
						rearmostAnalogInputPin = pinFromDigitalToAnalog(i);
					}
				} else if (PIN_AOUT.equals(config[i])) {
					if (pwmPins.indexOf(i) < 0) {
						printMessage("PWM is not available for pin " + i);
						throw new IllegalArgumentException("PWM is not available for pin " + i);
					}
					setPinMode(i, ARD_PIN_MODE_PWM);
					pinMode[i] = ARD_PIN_MODE_PWM;
				} else if (PIN_DIN.equals(config[i])) {
					if (analogPins.indexOf(i) < 0) {
						setPinMode(i, ARD_PIN_MODE_IN);
					} else {
						setPinMode(i + analogPinOffset, ARD_PIN_MODE_IN);
					}
					pinMode[i] = ARD_PIN_MODE_IN;
				} else if (PIN_DOUT.equals(config[i])) {
					if (analogPins.indexOf(i) < 0) {
						setPinMode(i, ARD_PIN_MODE_OUT);
					} else {
						setPinMode(i + analogPinOffset, ARD_PIN_MODE_OUT);						
					}
					pinMode[i] = ARD_PIN_MODE_OUT;
				} else if (PIN_SERVO.equals(config[i])) {
					setPinMode(i, ARD_PIN_MODE_SERVO);
					pinMode[i] = ARD_PIN_MODE_SERVO;
				} else {
					printMessage("A unsupported pin mode is specified for pin " + i);
					throw new IllegalArgumentException("A unsupported pin mode is specified for pin " + i);
				}
			} else {
				printMessage("The following pin number is out of range: " + i);
//				throw new IllegalArgumentException("The following pin number is out of range: " + i);
			}
		}
		endPacketIfNeeded();

		boolean wasNotInput = true;
		int from = 0;
		int to = 0;
		for (int i = digitalPins.get(0); i <= digitalPins.get(digitalPins.size() - 1); i++) {
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
		if (pinMode[digitalPins.get(digitalPins.size() - 1)] == ARD_PIN_MODE_IN) {
			to = digitalPins.get(digitalPins.size() - 1);
			PortRange range = new PortRange();
			range.setRange(from, to);
			dinPinChunks.add(range);
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
		int moduleId = ((Integer) arguments[0]).intValue();
		int start = ((Integer) arguments[1]).intValue();

		beginPacketIfNeeded(moduleId);
		for (int i = 0; i < (arguments.length - 2); i++) {
			int pin = start + i;
			int index = 2 + i;
			if (digitalPins.indexOf(pin) >= 0) {
				// converts from global pin number to local pin number
				// e.g. global pin number 6 means local pin number 0
				int pinNumber = pin - digitalPins.get(0);

				if (arguments[index] != null && arguments[index] instanceof Float) {
					if (pinMode[pin] == ARD_PIN_MODE_OUT) {
						digitalWrite(pinNumber, FLOAT_ZERO.equals(arguments[index]) ? 0 : 1);
					} else if (pinMode[pin] == ARD_PIN_MODE_PWM) {
						analogWrite(pinNumber, ((Float) arguments[index]).floatValue());
					} else if (pinMode[pin] == ARD_PIN_MODE_SERVO) {
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
			throw new IllegalArgumentException("The first argument of /polling is not an integer value"); //$NON-NLS-1$
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

		writeByte(ARD_SYSEX_START);
		writeByte(SAMPLING_INTERVAL);
		writeValueAsTwo7bitBytes(parent.getCommandPortServer().getSamplingInterval());
		writeByte(ARD_SYSEX_END);

		for (int pin = 0; pin < analogPins.size(); pin++) {
			if (pinMode[pinFromAnalogToDigital(pin)] == ARD_PIN_MODE_AIN) {
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
		for (int pin = 0; pin < analogPins.size(); pin++) {
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

		if (command == SYSEX_I2C_REQUEST) {
			if (i2cPins.size() < 2) {
				throw new IllegalArgumentException("no I2C pins are available");
			}
			
			int slaveAddress = ((Integer) arguments[3]).intValue();
			if ((slaveAddress < 0) || (slaveAddress > 127)) {
				throw new IllegalArgumentException("the slave address is out of range: " + Integer.toHexString(slaveAddress));
			}

			int readWriteMode = ((Integer) arguments[2]).intValue();
			if ((readWriteMode < 0) || (readWriteMode > 3)) {
				throw new IllegalArgumentException("read/write mode should be 0, 1, 2 or 3");
			}

			// TODO: Support 10 bit address mode if needed
			writeByte(slaveAddress); // slave address
			writeByte(readWriteMode << 3); // read/write
			for (int i = 4; i < arguments.length; i++) {
				int value = ((Integer) arguments[i]).intValue();
				writeValueAsTwo7bitBytes(value);
			}

			if (rearmostAnalogInputPin == pinFromDigitalToAnalog(i2cPins.get(1))) {
				for (int i = i2cPins.get(0) - 1; i > analogPins.get(0); i--) {
					if (pinMode[i] == ARD_PIN_MODE_AIN) {
						rearmostAnalogInputPin = this.pinFromDigitalToAnalog(i);
						break;
					}
				}
			}
		} else if (command == SERVO_CONFIG) {
			int pinNumber = ((Integer) arguments[2]).intValue();
			writeByte(pinNumber); // slave address
			for (int i = 3; i < arguments.length; i++) {
				int value = ((Integer) arguments[i]).intValue();
				writeValueAsTwo7bitBytes(value);
			}
		} else if (command == SAMPLING_INTERVAL) {
			for (int i = 2; i < arguments.length; i++) {
				int value = ((Integer) arguments[i]).intValue();
				writeValueAsTwo7bitBytes(value);
			}
		} else if (command == SYSEX_I2C_CONFIG) {
			if (protocolVersion[0] == 2 && protocolVersion[1] == 2) {
				/* I2C config (Firmata 2.2)
				 * -------------------------------
				 * 0  START_SYSEX (0xF0) (MIDI System Exclusive)
				 * 1  I2C_CONFIG (0x78)
				 * 2  Power pin settings (0:off or 1:on)
				 * 3  Delay in microseconds (LSB)
				 * 4  Delay in microseconds (MSB)
				 * ... user defined for special cases, etc
				 * n  END_SYSEX (0xF7)
				 */
				for (int i = 2; i < arguments.length; i++) {
					writeByte(((Integer) arguments[i]).intValue());
				}		
			} else {
				/* I2C config (Firmata 2.3)
				 * -------------------------------
				 * 0  START_SYSEX (0xF0) (MIDI System Exclusive)
				 * 1  I2C_CONFIG (0x78)
				 * 2  Delay in microseconds (LSB)
				 * 3  Delay in microseconds (MSB)
				 * ... user defined for special cases, etc
				 * n  END_SYSEX (0xF7)
				 */
				// Skip the power pin settings byte
				for (int i = 3; i < arguments.length; i++) {
					writeByte(((Integer) arguments[i]).intValue());
				}		
			}
		} else {
			for (int i = 2; i < arguments.length; i++) {
				writeByte(((Integer) arguments[i]).intValue());
			}
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
					processDigitalBytes(source, multiByteChannel[source], ((storedInputData[source][0] << 7) | storedInputData[source][1]));
					break;
				case ARD_REPORT_VERSION: // Report version
					protocolVersion[0] = storedInputData[source][0]; // minor
					protocolVersion[1] = storedInputData[source][1]; // major
					printMessage("Firmata Protocol Version: " + protocolVersion[1] + "." + protocolVersion[0]);
					firmwareVersionQueue.add(protocolVersion[1] + "." + protocolVersion[0]);
					break;
				case ARD_ANALOG_MESSAGE:
					digitalData[source][pinFromAnalogToDigital(multiByteChannel[source])] = (float) ((storedInputData[source][0] << 7) | storedInputData[source][1]) / 1023.0f;
					if (multiByteChannel[source] == rearmostAnalogInputPin) {
						notifyUpdate(source, analogPins.get(0), analogPins.size());
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
		int pin, mask;
		float lastValue = 0;

		for (int i = 0; i < digitalPins.size(); i++) {
			digitalPinUpdated[i] = false;
		}

		for (int i = 0; i < 8; i++) {
			pin = (port * 8) + i;
			if (analogPinOffset == 2 && port == 2) {
				pin = pin - analogPinOffset;
			}
			if (pin == 0 || pin == 1 || (pin > (digitalPins.size() - 1))) {
				// TODO: replace with proper implementation utilizing queried capabilities
				continue;
			}

			mask = 1 << i;
			lastValue = digitalData[source][pin];
			digitalData[source][pin] = ((value & mask) > 0) ? 1.0f : 0.0f;
			digitalPinUpdated[pin] = (lastValue != digitalData[source][pin]);
		}

		for (int j = 0; j < dinPinChunks.size(); j++) {
			boolean needToReport = false;
			PortRange range = dinPinChunks.get(j);
			for (pin = range.getMin(); pin <= range.getMax(); pin++) {
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
		if (((Integer) sysExMessage[1]).intValue() == FIRMATA_STRING) {
			String s = new String();
			for (int i = 0; i < counts; i++) {
				int data = sysExDataList.get(source).get(idx++);
				data += sysExDataList.get(source).get(idx++) << 7;
				s += String.valueOf((char) data);
			}
			sysExMessage[2] = new String(s);
			printMessage("STRING: " + s);
		} else if (((Integer) sysExMessage[1]).intValue() == CAPABILITY_RESPONSE) {
			int pinIndex = 0;
			String capabilities = "";

			digitalPins.clear();
			analogPins.clear();
			pwmPins.clear();
			servoPins.clear();
			i2cPins.clear();

			while (idx < sysExDataList.get(source).size()) {
				int data = sysExDataList.get(source).get(idx);
				if (data == 0x7F) {
					if (digitalPins.indexOf(pinIndex) < 0) {
						digitalPins.add(pinIndex);
					}
					if (capabilities.lastIndexOf(", ") == (capabilities.length() - 2)) {
						capabilities = capabilities.substring(0, capabilities.length() - 2);
					}
					printMessage("Pin " + pinIndex + ": " + capabilities);
					pinIndex++;
					capabilities = "";
				} else {
					if (data == ARD_PIN_MODE_IN) {
						capabilities += "Input, ";
					} else if (data == ARD_PIN_MODE_OUT) {
						capabilities += "Output, ";
					} else if (data == ARD_PIN_MODE_AIN) {
						capabilities += "Analog, ";
						if (analogPins.indexOf(pinIndex) < 0) {
							analogPins.add(pinIndex);
						}
					} else if (data == ARD_PIN_MODE_PWM) {
						capabilities += "PWM, ";
						if (pwmPins.indexOf(pinIndex) < 0) {
							pwmPins.add(pinIndex);
						}
					} else if (data == ARD_PIN_MODE_SERVO) {
						capabilities += "Servo, ";
						if (servoPins.indexOf(pinIndex) < 0) {
							servoPins.add(pinIndex);
						}
					} else if (data == ARD_PIN_MODE_I2C) {
						capabilities += "I2C, ";
						if (i2cPins.indexOf(pinIndex) < 0) {
							i2cPins.add(pinIndex);
						}
					}
					idx++;	// skip the resolution byte
				}
				idx++;
			}
			printMessage("Total configurable pins: " + pinIndex);

			instantiatePinRelatedVariables();

			if (!capabilitiesReceived.isEmpty()) {
				capabilitiesReceived.clear();
			}
			capabilitiesReceived.add("ready");
		} else if (((Integer) sysExMessage[1]).intValue() == REPORT_FIRMWARE) {
			int version = protocolVersion[1] * 10 + protocolVersion[0];
			if (version < 23) {
				printMessage("");
				printMessage("******************************************************");
				printMessage("WARNING");
				printMessage("You must upload StandardFirmata version 2.3 or greater");
				printMessage("from Arduino version 1.0 or higher");
				printMessage("******************************************************");
				printMessage("");
				if (version == 22) {
					analogPinOffset = 2;
				} else {
					analogPinOffset = 0;
				}

				instantiatePinRelatedVariables();

				if (!capabilitiesReceived.isEmpty()) {
					capabilitiesReceived.clear();
				}
				capabilitiesReceived.add("ready");
			} else {
				analogPinOffset = 0;

				// send a capability query
				writeByte(ARD_SYSEX_START);
				writeByte(CAPABILITY_QUERY);
				writeByte(ARD_SYSEX_END);
			}
			printMessage(Messages.getString("IOModule.Started") + port.getName() + ", " + port.getBaudRate());
		} else {
			for (int i = 0; i < counts; i++) {
				int data = sysExDataList.get(source).get(idx++);
				data += sysExDataList.get(source).get(idx++) << 7;
				sysExMessage[2 + i] = data;
			}
		}

		OSCMessage message = new OSCMessage("/sysex/reply", sysExMessage);
		if (parent.getCommandPortServer() != null) {
			parent.getCommandPortServer().sendMessageToClients(message);
		}
	}

	protected void setAnalogPinReporting(int pin, int mode) {
		writeByte(ARD_REPORT_ANALOG_PIN + pin);
		writeByte(mode);
	}

	protected void enableDigitalPinReporting() {
		boolean inputsAvailableInPort0 = false;
		boolean inputsAvailableInPort1 = false;
		boolean inputsAvailableInPort2 = false;

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
				// D14 and D15 are not available in port 1 under Firmata 2.2
				if (analogPinOffset == 2 && (analogPins.indexOf(pin) >= 0)) {
					continue;
				}

				if (range.contains(pin)) {
					inputsAvailableInPort1 = true;
				}
			}
			for (int pin = 16; pin < 24; pin++) {
				if (range.contains(pin - analogPinOffset)) {
					inputsAvailableInPort2 = true;
				}
			}
		}

		writeByte(ARD_REPORT_DIGITAL_PORTS | 0x00);
		writeByte(inputsAvailableInPort0 ? 1 : 0);

		writeByte(ARD_REPORT_DIGITAL_PORTS | 0x01);
		writeByte(inputsAvailableInPort1 ? 1 : 0);

		writeByte(ARD_REPORT_DIGITAL_PORTS | 0x02);
		writeByte(inputsAvailableInPort2 ? 1 : 0);
	}

	protected void disableDigitalPinReporting() {
		writeByte(ARD_REPORT_DIGITAL_PORTS | 0x00);
		writeByte(0);
		writeByte(ARD_REPORT_DIGITAL_PORTS | 0x01);
		writeByte(0);
		writeByte(ARD_REPORT_DIGITAL_PORTS | 0x02);
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
		} else if (pin < (16 - analogPinOffset)) {
			// D14 and D15 are not available in port 1 under Firmata 2.2
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
			writeByte(ARD_DIGITAL_MESSAGE | port);
			writeByte((stateOfDigitalPins >> (16 - analogPinOffset)) & 0x7F); // digital pins 16-22
			writeByte((stateOfDigitalPins & 0x800000) >> (23 - analogPinOffset)); // digital pins 23
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

	protected void writeValueAsTwo7bitBytes(int value) {
		writeByte(value & 0x7F); // LSB
		writeByte((value >> 7) & 0x7F); // MSB
	}

	abstract void writeByte(int data);

	private int pinFromDigitalToAnalog(int digitalPin) {
		return digitalPin - analogPins.get(0);
	}

	private int pinFromAnalogToDigital(int analogPin) {
		return analogPin + analogPins.get(0);
	}

}