/**
 * A hardware abstraction layer for the Gainer I/O module v1.0
 * 
 * @see http://gainer.cc
 */

package funnel;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Enumeration;

import com.illposed.osc.OSCBundle;
import com.illposed.osc.OSCMessage;

import gnu.io.CommPortIdentifier;
import gnu.io.SerialPort;
import gnu.io.SerialPortEvent;
import gnu.io.SerialPortEventListener;

public class GainerIO extends IOModule implements SerialPortEventListener {
	private SerialPort port;
	private InputStream input;
	private OutputStream output;

	private final int rate = 38400;
	private final int parity = SerialPort.PARITY_NONE;
	private final int databits = 8;
	private final int stopbits = SerialPort.STOPBITS_1;

	private funnel.BlockingQueue rebootCommandQueue;
	private funnel.BlockingQueue endCommandQueue;
	private funnel.BlockingQueue versionCommandQueue;
	private funnel.BlockingQueue ledCommandQueue;
	private funnel.BlockingQueue configCommandQueue;
	private funnel.BlockingQueue aoutCommandQueue;
	private funnel.BlockingQueue doutCommandQueue;

	private funnel.PortRange ainPortRange;
	private funnel.PortRange dinPortRange;
	private funnel.PortRange aoutPortRange;
	private funnel.PortRange doutPortRange;
	private funnel.PortRange buttonPortRange;

	private final static Integer CONFIGURATION_1[] = { PORT_AIN, PORT_AIN,
			PORT_AIN, PORT_AIN, PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN,
			PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_DOUT, PORT_DOUT,
			PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DIN };
	private final static Integer CONFIGURATION_2[] = { PORT_AIN, PORT_AIN,
			PORT_AIN, PORT_AIN, PORT_AIN, PORT_AIN, PORT_AIN, PORT_AIN,
			PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_DOUT, PORT_DOUT,
			PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DIN };
	private final static Integer CONFIGURATION_3[] = { PORT_AIN, PORT_AIN,
			PORT_AIN, PORT_AIN, PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN,
			PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT,
			PORT_AOUT, PORT_AOUT, PORT_DOUT, PORT_DIN };
	private final static Integer CONFIGURATION_4[] = { PORT_AIN, PORT_AIN,
			PORT_AIN, PORT_AIN, PORT_AIN, PORT_AIN, PORT_AIN, PORT_AIN,
			PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT,
			PORT_AOUT, PORT_AOUT, PORT_DOUT, PORT_DIN };
	private final static Integer CONFIGURATION_5[] = { PORT_DIN, PORT_DIN,
			PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN,
			PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN,
			PORT_DIN, PORT_DIN, };
	private final static Integer CONFIGURATION_6[] = { PORT_DOUT, PORT_DOUT,
			PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT,
			PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT,
			PORT_DOUT, PORT_DOUT, };
	private final static Integer CONFIGURATION_7[] = {
			PORT_AOUT,
			PORT_AOUT,
			PORT_AOUT,
			PORT_AOUT,
			PORT_AOUT,
			PORT_AOUT,
			PORT_AOUT,
			PORT_AOUT, // [0..7, 0]
			PORT_AOUT,
			PORT_AOUT,
			PORT_AOUT,
			PORT_AOUT,
			PORT_AOUT,
			PORT_AOUT,
			PORT_AOUT,
			PORT_AOUT, // [0..7, 1]
			PORT_AOUT, PORT_AOUT,
			PORT_AOUT,
			PORT_AOUT,
			PORT_AOUT,
			PORT_AOUT,
			PORT_AOUT,
			PORT_AOUT, // [0..7, 2]
			PORT_AOUT, PORT_AOUT, PORT_AOUT,
			PORT_AOUT,
			PORT_AOUT,
			PORT_AOUT,
			PORT_AOUT,
			PORT_AOUT, // [0..7, 3]
			PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT,
			PORT_AOUT,
			PORT_AOUT,
			PORT_AOUT,
			PORT_AOUT, // [0..7, 4]
			PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT,
			PORT_AOUT,
			PORT_AOUT,
			PORT_AOUT, // [0..7, 5]
			PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT,
			PORT_AOUT,
			PORT_AOUT, // [0..7, 6]
			PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT,
			PORT_AOUT, PORT_AOUT, // [0..7, 7]
	};
	private final static Integer CONFIGURATION_8[] = { PORT_DIN, PORT_DIN,
			PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN,
			PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT,
			PORT_DOUT, PORT_DOUT, };

	static private final String version = "?1.";

	private int configuration = 0;
	private float[] inputs;

	byte buffer[] = new byte[64];
	int bufferIndex;
	int bufferLast;
	int bufferSize = 64;

	private final static Integer LED_PORT = new Integer(16);
	private final static Float FLOAT_ZERO = new Float(0.0f);
	private int inputPortCounts = 0;

	public GainerIO(FunnelServer server, String serialPortName) {

		this.parent = server;
		parent.printMessage(Messages.getString("IOModule.Starting")); //$NON-NLS-1$

		rebootCommandQueue = new funnel.BlockingQueue();
		endCommandQueue = new funnel.BlockingQueue();
		versionCommandQueue = new funnel.BlockingQueue();
		ledCommandQueue = new funnel.BlockingQueue();
		configCommandQueue = new funnel.BlockingQueue();
		aoutCommandQueue = new funnel.BlockingQueue();
		doutCommandQueue = new funnel.BlockingQueue();
		ainPortRange = new funnel.PortRange();
		dinPortRange = new funnel.PortRange();
		aoutPortRange = new funnel.PortRange();
		doutPortRange = new funnel.PortRange();
		buttonPortRange = new funnel.PortRange();

		try {
			Enumeration portList = CommPortIdentifier.getPortIdentifiers();

			while (portList.hasMoreElements()) {
				CommPortIdentifier portId = (CommPortIdentifier) portList
						.nextElement();
				if (portId.getPortType() == CommPortIdentifier.PORT_SERIAL) {
					if (openSerialPort(portId)) {
						if (isGainerIO(serialPortName)) {
							parent.printMessage(Messages
									.getString("IOModule.Started") //$NON-NLS-1$
									+ portId.getName());
							break;
						} else {
							parent.printMessage("tried: " + portId.getName());
							closeSerialPort();
						}
					}
				}
			}
		} catch (Exception e) {
			printMessage(Messages.getString("IOModule.InsideSerialError")); //$NON-NLS-1$
			e.printStackTrace();
			port = null;
			input = null;
			output = null;
		}

		if (port == null) {
			printMessage(Messages.getString("IOModule.PortNotFoundError")); //$NON-NLS-1$
			throw new IllegalArgumentException(""); //$NON-NLS-1$
		}
	}

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

	public Object[] getInputs(String address, Object[] arguments)
			throws IllegalArgumentException {
		int moduleId = 0;
		int from = 0;
		int counts = inputs.length;

		if (address.equals("/in")) { //$NON-NLS-1$
			moduleId = ((Integer) arguments[0]).intValue();
			from = ((Integer) arguments[1]).intValue();
			counts = ((Integer) arguments[2]).intValue();
		} else if (address.equals("/in/*")) { //$NON-NLS-1$
			moduleId = ((Integer) arguments[0]).intValue();
			from = 0;
			counts = inputs.length;
		}

		if ((from + counts) > inputs.length) {
			counts = inputs.length - from;
		}

		if ((from >= inputs.length) || (counts <= 0)) {
			throw new IllegalArgumentException(""); //$NON-NLS-1$
		}

		Object[] results = new Object[2 + counts];
		results[0] = new Integer(moduleId); // TODO: Support multiple modules
		results[1] = new Integer(from);
		for (int i = 0; i < counts; i++) {
			results[2 + i] = new Float(inputs[from + i]);
		}
		return results;
	}

	public OSCBundle getAllInputsAsBundle() {
		if (inputs == null || !this.isPolling || this.inputPortCounts < 1) {
			return null;
		} else {
			OSCBundle bundle = new OSCBundle();

			if (ainPortRange.getCounts() > 0) {
				Object[] ainArguments = new Object[2 + ainPortRange.getCounts()];
				ainArguments[0] = new Integer(0); // TODO: Support multiple
				// modules
				ainArguments[1] = new Integer(ainPortRange.getMin());
				for (int i = 0; i < ainPortRange.getCounts(); i++) {
					ainArguments[2 + i] = new Float(inputs[ainPortRange
							.getMin()
							+ i]);
				}
				bundle.addPacket(new OSCMessage("/in", ainArguments)); //$NON-NLS-1$
			}

			if (dinPortRange.getCounts() > 0) {
				Object[] dinArguments = new Object[2 + dinPortRange.getCounts()];
				dinArguments[0] = new Integer(0);
				dinArguments[1] = new Integer(dinPortRange.getMin());
				for (int i = 0; i < dinPortRange.getCounts(); i++) {
					dinArguments[2 + i] = new Float(inputs[dinPortRange
							.getMin()
							+ i]);
				}
				bundle.addPacket(new OSCMessage("/in", dinArguments)); //$NON-NLS-1$
			}

			if (buttonPortRange.getCounts() > 0) {
				Object[] buttonArguments = new Object[3];
				buttonArguments[0] = new Integer(0);
				buttonArguments[1] = new Integer(buttonPortRange.getMin());
				buttonArguments[2] = new Float(inputs[buttonPortRange.getMin()]);
				bundle.addPacket(new OSCMessage("/in", buttonArguments)); //$NON-NLS-1$
			}

			return bundle;
		}
	}

	public void reboot() {
		if (this.port == null) {
			return;
		}

		printMessage(Messages.getString("IOModule.Rebooting")); //$NON-NLS-1$
		write("Q*"); //$NON-NLS-1$
		rebootCommandQueue.pop(1000);
		rebootCommandQueue.sleep(100);
		write("?*"); //$NON-NLS-1$
		String versionString = (String) versionCommandQueue.pop(1000);
		printMessage(Messages.getString("IOModule.Rebooted")); //$NON-NLS-1$
		printMessage(Messages.getString("IOModule.FirmwareVesrion") + versionString.substring(1, 9)); //$NON-NLS-1$
	}

	synchronized public void serialEvent(SerialPortEvent serialEvent) {
		if (serialEvent.getEventType() == SerialPortEvent.DATA_AVAILABLE) {
			try {
				while (input.available() > 0) {
					synchronized (buffer) {
						if (bufferLast == buffer.length) {
							byte temp[] = new byte[bufferLast << 1];
							System.arraycopy(buffer, 0, temp, 0, bufferLast);
							buffer = temp;
						}
						buffer[bufferLast++] = (byte) input.read();

						if (buffer[bufferLast - 1] == '*') {
							String command = readStringUntil('*');
							dispatch(command);
							clear();
						} else {
							continue;
						}
					}
				}
			} catch (IOException e) {

			}

		}
	}

	public void setConfiguration(Object[] arguments) {
		inputs = null;
		if (java.util.Arrays.equals(CONFIGURATION_1, arguments)) {
			configuration = 1;
			ainPortRange.setRange(0, 3);
			dinPortRange.setRange(4, 7);
			aoutPortRange.setRange(8, 11);
			doutPortRange.setRange(12, 15);
			buttonPortRange.setRange(17, 17);
			inputs = new float[18];
			inputPortCounts = ainPortRange.getCounts()
					+ dinPortRange.getCounts() + buttonPortRange.getCounts();
		} else if (java.util.Arrays.equals(CONFIGURATION_2, arguments)) {
			configuration = 2;
			ainPortRange.setRange(0, 7);
			dinPortRange.setRange(-1, -1);
			aoutPortRange.setRange(8, 11);
			doutPortRange.setRange(12, 15);
			buttonPortRange.setRange(17, 17);
			inputs = new float[18];
			inputPortCounts = ainPortRange.getCounts()
					+ dinPortRange.getCounts() + buttonPortRange.getCounts();
		} else if (java.util.Arrays.equals(CONFIGURATION_3, arguments)) {
			configuration = 3;
			ainPortRange.setRange(0, 3);
			dinPortRange.setRange(4, 7);
			aoutPortRange.setRange(8, 15);
			doutPortRange.setRange(-1, -1);
			buttonPortRange.setRange(17, 17);
			inputs = new float[18];
			inputPortCounts = ainPortRange.getCounts()
					+ dinPortRange.getCounts() + buttonPortRange.getCounts();
		} else if (java.util.Arrays.equals(CONFIGURATION_4, arguments)) {
			configuration = 4;
			ainPortRange.setRange(0, 7);
			dinPortRange.setRange(-1, -1);
			aoutPortRange.setRange(8, 15);
			doutPortRange.setRange(-1, -1);
			buttonPortRange.setRange(17, 17);
			inputs = new float[18];
			inputPortCounts = ainPortRange.getCounts()
					+ dinPortRange.getCounts() + buttonPortRange.getCounts();
		} else if (java.util.Arrays.equals(CONFIGURATION_5, arguments)) {
			configuration = 5;
			ainPortRange.setRange(-1, -1);
			dinPortRange.setRange(0, 15);
			aoutPortRange.setRange(-1, -1);
			doutPortRange.setRange(-1, -1);
			buttonPortRange.setRange(-1, -1);
			inputs = new float[16];
			inputPortCounts = dinPortRange.getCounts();
		} else if (java.util.Arrays.equals(CONFIGURATION_6, arguments)) {
			configuration = 6;
			ainPortRange.setRange(-1, -1);
			dinPortRange.setRange(-1, -1);
			aoutPortRange.setRange(-1, -1);
			doutPortRange.setRange(0, 15);
			buttonPortRange.setRange(-1, -1);
			inputs = new float[16];
			inputPortCounts = 0;
		} else if (java.util.Arrays.equals(CONFIGURATION_7, arguments)) {
			configuration = 7;
			ainPortRange.setRange(-1, -1);
			dinPortRange.setRange(-1, -1);
			aoutPortRange.setRange(0, 63);
			doutPortRange.setRange(-1, -1);
			buttonPortRange.setRange(-1, -1);
			inputs = new float[64];
			inputPortCounts = 0;
		} else if (java.util.Arrays.equals(CONFIGURATION_8, arguments)) {
			configuration = 8;
			ainPortRange.setRange(-1, -1);
			dinPortRange.setRange(0, 7);
			aoutPortRange.setRange(-1, -1);
			doutPortRange.setRange(8, 15);
			buttonPortRange.setRange(-1, -1);
			inputs = new float[16];
			inputPortCounts = dinPortRange.getCounts();
		} else {
			throw new IllegalArgumentException(
					"Can't find such a configuration"); //$NON-NLS-1$
		}
		write("KONFIGURATION_" + configuration + "*"); //$NON-NLS-1$ //$NON-NLS-2$
		String configurationString = (String) configCommandQueue.pop(1000);
		printMessage("configuration: " + configurationString); //$NON-NLS-1$
		configCommandQueue.sleep(100);
	}

	public void setOutput(Object[] arguments) {
		int start = ((Integer) arguments[1]).intValue();
		float depth = (configuration == 7) ? 15.0f : 255.0f;
		for (int i = 2; i < arguments.length; i++) {
			if (arguments[i] == null) {
				throw new IllegalArgumentException("argument " + i + " is null");
			} else if (!(arguments[i] instanceof Float)) {
				throw new IllegalArgumentException("argument " + i
						+ " is not Float");
			}
		}
		if (arguments.length == 3) {
			for (int i = 0; i < (arguments.length - 2); i++) {
				int port = start + i;
				int index = 2 + i;
				if ((configuration == 7) && aoutPortRange.contains(port)) {
					inputs[port] = ((Float) arguments[index]).floatValue();
					scanMatrix(port / 8);
				} else if (doutPortRange.contains(port)) {
					if (FLOAT_ZERO.equals(arguments[index])) {
						setDigitalOutputLow(port);
					} else {
						setDigitalOutputHigh(port);
					}
					inputs[port] = ((Float) arguments[index]).floatValue();
				} else if (aoutPortRange.contains(port)) {
					setAnalogOutput(port, (int) (((Float) arguments[index])
							.floatValue() * depth));
					inputs[port] = ((Float) arguments[index]).floatValue();
				} else if (LED_PORT.intValue() == port) {
					if (FLOAT_ZERO.equals(arguments[index])) {
						write("l*"); //$NON-NLS-1$
						ledCommandQueue.pop(1000);
					} else {
						write("h*"); //$NON-NLS-1$
						ledCommandQueue.pop(1000);
					}
					inputs[port] = ((Float) arguments[index]).floatValue();
				}
			}
		} else {
			int[] analogValues = new int[aoutPortRange.getCounts()];
			for (int i = 0; i < aoutPortRange.getCounts(); i++) {
				analogValues[i] = (int) (inputs[aoutPortRange.getMin() + i] * depth);
			}
			int digitalValues = 0x0000;
			for (int i = 0; i < doutPortRange.getCounts(); i++) {
				digitalValues |= (int) inputs[doutPortRange.getMin() + i] << i;
			}
			boolean hasAnalogValues = false;
			boolean hasDigitalValues = false;
			for (int i = 0; i < (arguments.length - 2); i++) {
				int port = start + i;
				int index = 2 + i;
				if (doutPortRange.contains(port)) {
					int bitsToShift = port - doutPortRange.getMin();
					if (((Float) arguments[index]).intValue() == 0) {
						digitalValues &= ~(1 << bitsToShift);
						inputs[port] = 0.0f;
					} else {
						digitalValues |= 1 << bitsToShift;
						inputs[port] = 1.0f;
					}
					hasDigitalValues = true;
				} else if (aoutPortRange.contains(port)) {
					analogValues[port - aoutPortRange.getMin()] = (int) (((Float) arguments[index])
							.floatValue() * depth);
					inputs[port] = ((Float) arguments[index]).floatValue();
					hasAnalogValues = true;
				} else if (LED_PORT.intValue() == port) {
					if (FLOAT_ZERO.equals(arguments[index])) {
						write("l*"); //$NON-NLS-1$
						ledCommandQueue.pop(1000);
					} else {
						write("h*"); //$NON-NLS-1$
						ledCommandQueue.pop(1000);
					}
					inputs[port] = ((Float) arguments[index]).floatValue();
				}
			}
			if (hasAnalogValues) {
				if (configuration == 7) {
					int from = start / 8;
					int to = (start + arguments.length - 3) / 8;
					for (int line = from; line <= to; line++) {
						scanMatrix(line);
					}
				} else {
					setAnalogOutputs(analogValues, hasDigitalValues);
				}
			}
			if (hasDigitalValues) {
				setDigitalOutputs(digitalValues);
				if (hasAnalogValues) {
					// let's pop the queue to clear
					aoutCommandQueue.pop(1000);
				}
			}
		}
	}

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

	public void startPolling() {
		if (port == null) {
			return;
		}

		if (ainPortRange.getCounts() > 0) {
			printMessage("polling started: ain"); //$NON-NLS-1$
			write("i*"); //$NON-NLS-1$
		}
		configCommandQueue.sleep(100);
		if (dinPortRange.getCounts() > 0) {
			printMessage("polling started: din"); //$NON-NLS-1$
			write("r*"); //$NON-NLS-1$
		}
		this.isPolling = true;
	}

	public void stopPolling() {
		if (port == null) {
			return;
		}

		this.isPolling = false;
		printMessage("polling stopped"); //$NON-NLS-1$
		write("E*"); //$NON-NLS-1$
		endCommandQueue.pop(1000);
	}

	private void clear() {
		bufferLast = 0;
		bufferIndex = 0;
	}

	private void dispatch(String command) {
		if (command.equals("Q*")) { //$NON-NLS-1$
			rebootCommandQueue.push(new Integer(0));
		} else if (command.equals("E*")) { //$NON-NLS-1$
			endCommandQueue.push(new Integer(0));
		} else if (command.startsWith("?")) { //$NON-NLS-1$
			versionCommandQueue.push(command);
		} else if (command.startsWith("KONFIGURATION_")) { //$NON-NLS-1$
			configCommandQueue.push(command);
		} else if (command.equals("h*") || command.equals("l*")) { //$NON-NLS-1$ //$NON-NLS-2$
			ledCommandQueue.push(command);
		} else if (command.startsWith("a") || command.startsWith("A")) { //$NON-NLS-1$ //$NON-NLS-2$
			aoutCommandQueue.push(command);
		} else if (command.startsWith("H") || command.startsWith("L") //$NON-NLS-1$ //$NON-NLS-2$
				|| command.startsWith("D")) { //$NON-NLS-1$
			doutCommandQueue.push(command);
		} else if (command.startsWith("i") || command.startsWith("I")) { //$NON-NLS-1$ //$NON-NLS-2$
			String value;
			for (int i = 0; i < ainPortRange.getCounts(); i++) {
				value = command.substring(2 * i + 1, 2 * (i + 1) + 1);
				inputs[ainPortRange.getMin() + i] = (float) Integer.parseInt(
						value, 16) / 255.0f;
			}
		} else if (command.startsWith("r") || command.startsWith("R")) { //$NON-NLS-1$ //$NON-NLS-2$
			int value = Integer.parseInt(command.substring(1, 5), 16);
			for (int i = 0; i < dinPortRange.getCounts(); i++) {
				int c = 1 & (value >> i);
				if (c == 1) {
					inputs[dinPortRange.getMin() + i] = 1.0f;
				} else {
					inputs[dinPortRange.getMin() + i] = 0.0f;
				}
			}
		} else if (command.equals("F*") || command.equals("N*")) { //$NON-NLS-1$ //$NON-NLS-2$
			inputs[buttonPortRange.getMin()] = command.equals("N*") ? 1.0f //$NON-NLS-1$
					: 0.0f;
		} else {
			System.out.print("unknown: " + command); //$NON-NLS-1$
		}
	}

	private byte[] readBytesUntil(int interesting) {
		if (bufferIndex == bufferLast)
			return null;
		byte what = (byte) interesting;

		synchronized (buffer) {
			int found = -1;
			for (int k = bufferIndex; k < bufferLast; k++) {
				if (buffer[k] == what) {
					found = k;
					break;
				}
			}
			if (found == -1)
				return null;

			int length = found - bufferIndex + 1;
			byte outgoing[] = new byte[length];
			System.arraycopy(buffer, bufferIndex, outgoing, 0, length);

			bufferIndex = 0; // rewind
			bufferLast = 0;
			return outgoing;
		}
	}

	private String readStringUntil(int interesting) {
		byte b[] = readBytesUntil(interesting);
		if (b == null)
			return null;
		return new String(b);
	}

	private void setAnalogOutput(int ch, int value) {
		if (aoutPortRange.contains(ch)) {
			int outChannel = ch - aoutPortRange.getMin();
			String s = "a" + Integer.toHexString(outChannel).toUpperCase(); //$NON-NLS-1$
			value = value < 0 ? 0 : value;
			value = value > 255 ? 255 : value;

			String sv = value < 16 ? "0" : ""; //$NON-NLS-1$ //$NON-NLS-2$
			sv += Integer.toHexString(value).toUpperCase();
			s += sv;
			s += "*"; //$NON-NLS-1$
			write(s);
			aoutCommandQueue.pop(1000);
		} else {
			throw new IndexOutOfBoundsException(
					"Gainer error!! out of bounds analog out"); //$NON-NLS-1$
		}
	}

	private void setAnalogOutputs(int[] values, boolean async) {
		String s = "A";
		String sv = "";

		if (aoutPortRange.getCounts() != values.length) {
			throw new IndexOutOfBoundsException(
					"Gainer error!! - number of analog outputs are wrong");
		}

		for (int i = 0; i < values.length; i++) {
			values[i] = values[i] < 0 ? 0 : values[i];
			values[i] = values[i] > 255 ? 255 : values[i];
			sv = values[i] < 16 ? "0" : "";
			sv += Integer.toHexString(values[i]).toUpperCase();
			s += sv;
		}
		s += "*";
		write(s);
		if (!async) {
			aoutCommandQueue.pop(1000);
		}
	}

	private void scanMatrix(int line) {
		String s = "a";
		s += Integer.toHexString(line).toUpperCase();

		int offset = line * 8;
		for (int i = 0; i < 8; i++) {
			int index = offset + i;
			inputs[index] = inputs[index] < 0.0f ? 0.0f : inputs[index];
			inputs[index] = inputs[index] > 1.0f ? 1.0f : inputs[index];
			s += Integer.toHexString((int) (inputs[index] * 15.0f + 0.5f))
					.toUpperCase();
		}
		s += "*";
		write(s);
	}

	// private void setDigitalOutput(boolean[] values) {
	// int chs = 0;
	// if (doutPortRange.getCounts() == values.length) {
	// for (int i = 0; i < values.length; i++) {
	// if (values[i]) {
	// chs |= (1 << i);
	// }
	// }
	// } else {
	// throw new IndexOutOfBoundsException("Out of bounds: dout");
	// }
	// String val = Integer.toHexString(chs).toUpperCase();
	// String sv = "";
	// for (int i = 0; i < doutPortRange.getCounts() - val.length(); i++) {
	// sv += "0";
	// }
	// sv += val;
	//
	// String s = "D" + sv + "*";
	// write(s);
	// doutCommandQueue.pop(1000);
	// }

	private void setDigitalOutputs(int chs) {
		if (chs <= 0xFFFF) {
			String val = Integer.toHexString(chs).toUpperCase();
			String sv = "";
			for (int i = 0; i < 4 - val.length(); i++) {
				sv += "0";
			}
			sv += val;

			String s = "D" + sv + "*";
			write(s);
			doutCommandQueue.pop(1000);
		} else {
			throw new IndexOutOfBoundsException("Out of bounds: dout");
		}
	}

	private void setDigitalOutputHigh(int ch) {
		if (doutPortRange.contains(ch)) {
			int outChannel = ch - doutPortRange.getMin();
			String s = "H" + Integer.toHexString(outChannel).toUpperCase() + "*"; //$NON-NLS-1$ //$NON-NLS-2$
			write(s);
			doutCommandQueue.pop(1000);
		} else {
			throw new IndexOutOfBoundsException(
					"Gainer error!! out of bounds digital out"); //$NON-NLS-1$
		}
	}

	private void setDigitalOutputLow(int ch) {
		if (doutPortRange.contains(ch)) {
			int outChannel = ch - doutPortRange.getMin();
			String s = "L" + Integer.toHexString(outChannel).toUpperCase() + "*"; //$NON-NLS-1$ //$NON-NLS-2$
			write(s);
			doutCommandQueue.pop(1000);
		} else {
			throw new IndexOutOfBoundsException(
					"Gainer error!! out of bounds digital out"); //$NON-NLS-1$
		}
	}

	private void write(String what) {
		try {
			output.write(what.getBytes());
			output.flush();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	private boolean openSerialPort(CommPortIdentifier portId) {
		try {
			port = (SerialPort) portId.open("GainerSerialPort", 2000);
			input = port.getInputStream();
			output = port.getOutputStream();
			port.setSerialPortParams(rate, databits, stopbits, parity);
			port.addEventListener(this);
			port.notifyOnDataAvailable(true);
		} catch (gnu.io.PortInUseException e) {
			printMessage(e.toString());
			return false;
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
		return true;
	}

	private void closeSerialPort() {
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
			if (port != null) {
				port.notifyOnDataAvailable(false);
				port.removeEventListener();
				port.close();
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		port = null;
	}

	private boolean isGainerIO(String specifiedName) {
		String portName = port.getName();
		if (specifiedName != null) {
			return portName.equals(specifiedName);
		} else {
			try {
				write("Q*"); //$NON-NLS-1$
				rebootCommandQueue.pop(100);
				rebootCommandQueue.sleep(100);
				write("?*"); //$NON-NLS-1$
				String versionString = (String) versionCommandQueue.pop(100);
				if (versionString == null) {
					return false;
				} else {
					return versionString.startsWith(version);
				}
			} catch (Exception e) {
				e.printStackTrace();
				return false;
			}
		}
	}
}
