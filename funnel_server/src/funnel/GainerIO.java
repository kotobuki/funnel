package funnel;

/**
 * Serial class
 *
 * @author PDP Project
 * @version 1.0
 */

import gnu.io.CommPortIdentifier;
import gnu.io.SerialPort;
import gnu.io.SerialPortEvent;
import gnu.io.SerialPortEventListener;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Enumeration;
import java.util.concurrent.LinkedBlockingQueue;

import com.illposed.osc.OSCMessage;

public class GainerIO extends IOModule implements SerialPortEventListener {
	private SerialPort port;
	private InputStream input;
	private OutputStream output;
	private FunnelServer parent;

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

	private final int PORT_AIN = 0;
	private final int PORT_DIN = 1;
	private final int PORT_AOUT = 2;
	private final int PORT_DOUT = 3;

	private final Integer CONFIGURATION_1[] = { PORT_AIN, PORT_AIN, PORT_AIN,
			PORT_AIN, PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN, PORT_AOUT,
			PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT,
			PORT_DOUT, PORT_DOUT, PORT_DIN };
	private final Integer CONFIGURATION_2[] = { PORT_AIN, PORT_AIN, PORT_AIN,
			PORT_AIN, PORT_AIN, PORT_AIN, PORT_AIN, PORT_AIN, PORT_AOUT,
			PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT,
			PORT_DOUT, PORT_DOUT, PORT_DIN };
	private final Integer CONFIGURATION_3[] = { PORT_AIN, PORT_AIN, PORT_AIN,
			PORT_AIN, PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN, PORT_AOUT,
			PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT,
			PORT_AOUT, PORT_DOUT, PORT_DIN };
	private final Integer CONFIGURATION_4[] = { PORT_AIN, PORT_AIN, PORT_AIN,
			PORT_AIN, PORT_AIN, PORT_AIN, PORT_AIN, PORT_AIN, PORT_AOUT,
			PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT,
			PORT_AOUT, PORT_DOUT, PORT_DIN };
	private final Integer CONFIGURATION_5[] = { PORT_DIN, PORT_DIN, PORT_DIN,
			PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN,
			PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN,
			PORT_DIN, };
	private final Integer CONFIGURATION_6[] = { PORT_DOUT, PORT_DOUT,
			PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT,
			PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT,
			PORT_DOUT, PORT_DOUT, };
	private final Integer CONFIGURATION_7[] = {
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
	private final Integer CONFIGURATION_8[] = { PORT_DIN, PORT_DIN, PORT_DIN,
			PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN, PORT_DOUT,
			PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT,
			PORT_DOUT, };

	private int configuration = 0;

	private float[] inputs;

	private LinkedBlockingQueue<OSCMessage> notifierQueue;

	byte buffer[] = new byte[64];
	int bufferIndex;
	int bufferLast;
	int bufferSize = 64;

	Integer ledPort;

	Float zero;

	public GainerIO(FunnelServer server, String serialPortName,
			LinkedBlockingQueue<OSCMessage> notifierQueue) {

		this.parent = server;
		this.notifierQueue = notifierQueue;
		parent.printMessage("Starting the Gainer I/O module...");

		try {
			Enumeration portList = CommPortIdentifier.getPortIdentifiers();

			while (portList.hasMoreElements()) {
				CommPortIdentifier portId = (CommPortIdentifier) portList
						.nextElement();

				if (portId.getPortType() == CommPortIdentifier.PORT_SERIAL) {
					if (portId.getName().equals(serialPortName)) {
						port = (SerialPort) portId.open("serial gainer", 2000);
						input = port.getInputStream();
						output = port.getOutputStream();
						port.setSerialPortParams(rate, databits, stopbits,
								parity);
						port.addEventListener(this);
						port.notifyOnDataAvailable(true);

						parent.printMessage("GAINER started on port "
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
		ledPort = new Integer(16);
		zero = new Float(0.0);
	}

	// シリアルポートを停止する
	public void dispose() {
		port.removeEventListener();
		printMessage("dispose Gainer ..");
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
		int from = 0;
		int counts = inputs.length;

		if (address.equals("/in")) {
			from = (Integer) arguments[0];
			counts = (Integer) arguments[1];
		} else if (address.equals("/in/*")) {
			from = 0;
			counts = inputs.length;
		} else if (address.startsWith("/in/[")) {
			from = Integer
					.parseInt(address.substring(5, address.indexOf("..")));
			counts = Integer.parseInt(address.substring(
					address.indexOf("..") + 2, address.length() - 1))
					- from;
		}

		if ((from + counts) > inputs.length) {
			counts = inputs.length - from;
		}

		if ((from >= inputs.length) || (counts <= 0)) {
			throw new IllegalArgumentException("");
		}

		Object[] results = new Object[1 + counts];
		results[0] = new Integer(from);
		for (int i = 0; i < counts; i++) {
			results[1 + i] = new Float(inputs[from + i]);
		}
		return results;
	}

	public void reboot() {
		write("Q*");
		rebootCommandQueue.pop(1000);
		rebootCommandQueue.sleep(100);
		write("?*");
		String versionString = (String) versionCommandQueue.pop(1000);
		printMessage("version: " + versionString);
	}

	// シリアルから入力があったら
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
							// parent.sendToFlash(readStringUntil('*'));
							String command = readStringUntil('*');
							// printMessage(command);
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
			inputs = new float[18];
		} else if (java.util.Arrays.equals(CONFIGURATION_2, arguments)) {
			configuration = 2;
			ainPortRange.setRange(0, 7);
			dinPortRange.setRange(-1, -1);
			aoutPortRange.setRange(8, 11);
			doutPortRange.setRange(12, 15);
			inputs = new float[18];
		} else if (java.util.Arrays.equals(CONFIGURATION_3, arguments)) {
			configuration = 3;
			ainPortRange.setRange(0, 3);
			dinPortRange.setRange(4, 7);
			aoutPortRange.setRange(8, 15);
			doutPortRange.setRange(-1, -1);
			inputs = new float[18];
		} else if (java.util.Arrays.equals(CONFIGURATION_4, arguments)) {
			configuration = 4;
			ainPortRange.setRange(0, 7);
			dinPortRange.setRange(-1, -1);
			aoutPortRange.setRange(8, 15);
			doutPortRange.setRange(-1, -1);
			inputs = new float[18];
		} else if (java.util.Arrays.equals(CONFIGURATION_5, arguments)) {
			configuration = 5;
			ainPortRange.setRange(-1, -1);
			dinPortRange.setRange(0, 15);
			aoutPortRange.setRange(-1, -1);
			doutPortRange.setRange(-1, -1);
			inputs = new float[16];
		} else if (java.util.Arrays.equals(CONFIGURATION_6, arguments)) {
			configuration = 6;
			ainPortRange.setRange(-1, -1);
			dinPortRange.setRange(-1, -1);
			aoutPortRange.setRange(-1, -1);
			doutPortRange.setRange(0, 15);
			inputs = new float[16];
		} else if (java.util.Arrays.equals(CONFIGURATION_7, arguments)) {
			configuration = 7;
			ainPortRange.setRange(0, 63);
			dinPortRange.setRange(-1, -1);
			aoutPortRange.setRange(-1, -1);
			doutPortRange.setRange(-1, -1);
			inputs = new float[64];
		} else if (java.util.Arrays.equals(CONFIGURATION_8, arguments)) {
			configuration = 8;
			ainPortRange.setRange(-1, -1);
			dinPortRange.setRange(0, 7);
			aoutPortRange.setRange(-1, -1);
			doutPortRange.setRange(8, 15);
			inputs = new float[16];
		} else {
			throw new IllegalArgumentException(
					"Can't find such a configuration");
		}
		write("KONFIGURATION_" + configuration + "*");
		String configurationString = (String) configCommandQueue.pop(1000);
		printMessage("configuration: " + configurationString);
		configCommandQueue.sleep(100);
	}

	public void setOutput(Object[] arguments) {
		printMessage("arguments: " + arguments[0] + ", " + arguments[1]);
		if (aoutPortRange.contains((Integer) arguments[0])) {
			for (int i = 0; i < aoutPortRange.getMax(); i++) {
				if (arguments[i + 1] != null
						&& arguments[i + 1] instanceof Float) {
					setAnalogOutput(i,
							(int) ((Float) arguments[i + 1] * 255.0f));
				}
			}
		} else if (doutPortRange.contains((Integer) arguments[0])) {
			for (int i = 0; i < doutPortRange.getMax(); i++) {
				if (arguments[i + 1] != null) {
					if (zero.equals(arguments[i + 1])) {
						setDigitalOutputLow(i);
					} else {
						setDigitalOutputHigh(i);
					}
				}
			}
		} else if (ledPort.equals(arguments[0])) {
			if (zero.equals(arguments[1])) {
				write("l*");
				ledCommandQueue.pop(1000);
			} else {
				write("h*");
				ledCommandQueue.pop(1000);
			}
		}
	}

	public void setPolling(Object[] arguments) {
		if (arguments[0] instanceof Integer) {
			if (new Integer(1).equals(arguments[0])) {
				if (ainPortRange.getCounts() > 0) {
					printMessage("polling started: ain");
					write("i*");
				}
				configCommandQueue.sleep(100);
				if (dinPortRange.getCounts() > 0) {
					printMessage("polling started: din");
					write("r*");
				}
			} else {
				printMessage("polling stopped");
				write("E*");
				endCommandQueue.pop(1000);
			}
		} else {
			throw new IllegalArgumentException(
					"The first argument of /polling is not an integer value");
		}
	}

	public void stopPolling() {
		if (port != null) {
			printMessage("polling stopped");
			write("E*");
			endCommandQueue.pop(1000);
		}
	}

	// バッファを空にする
	private void clear() {
		bufferLast = 0;
		bufferIndex = 0;
	}

	private void dispatch(String command) {
		if (command.equals("Q*")) {
			rebootCommandQueue.push(new Integer(0));
		} else if (command.equals("E*")) {
			endCommandQueue.push(new Integer(0));
		} else if (command.startsWith("?")) {
			versionCommandQueue.push(command);
		} else if (command.startsWith("KONFIGURATION_")) {
			configCommandQueue.push(command);
		} else if (command.equals("h*") || command.equals("l*")) {
			ledCommandQueue.push(command);
		} else if (command.startsWith("a") || command.startsWith("A")) {
			aoutCommandQueue.push(command);
		} else if (command.startsWith("H") || command.startsWith("L")
				|| command.startsWith("D")) {
			doutCommandQueue.push(command);
		} else if (command.startsWith("i") || command.startsWith("I")) {
			String value;
			for (int i = 0; i < ainPortRange.getCounts(); i++) {
				value = command.substring(2 * i + 1, 2 * (i + 1) + 1);
				inputs[ainPortRange.getMin() + i] = (float) Integer.parseInt(
						value, 16) / 255.0f;
			}
			Object arguments[] = new Object[1 + ainPortRange.getCounts()];
			arguments[0] = new Integer(ainPortRange.getMin());
			for (int i = 0; i < ainPortRange.getCounts(); i++) {
				arguments[1 + i] = new Float(inputs[ainPortRange.getMin() + i]);
			}
			OSCMessage message = new OSCMessage("/in", arguments);
			try {
				notifierQueue.put(message);
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
		} else if (command.startsWith("r") || command.startsWith("R")) {
			int value = Integer.parseInt(command.substring(1, 5), 16);
			for (int i = 0; i < dinPortRange.getCounts(); i++) {
				int c = 1 & (value >> i);
				if (c == 1) {
					inputs[dinPortRange.getMin() + i] = 1.0f;
				} else {
					inputs[dinPortRange.getMin() + i] = 0.0f;
				}
			}
			Object arguments[] = new Object[1 + dinPortRange.getCounts()];
			arguments[0] = new Integer(dinPortRange.getMin());
			for (int i = 0; i < dinPortRange.getCounts(); i++) {
				arguments[1 + i] = new Float(inputs[dinPortRange.getMin() + i]);
			}
			OSCMessage message = new OSCMessage("/in", arguments);
			try {
				notifierQueue.put(message);
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
		} else {
			System.out.print("unknown: " + command);
		}
	}

	// メッセージをテキストエリアに出力
	private void printMessage(String msg) {
		parent.printMessage(msg);
	}

	// 指定した文字までバッファを読みバイト列で返す
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

	// 指定した文字までバッファを読み文字列で返す
	private String readStringUntil(int interesting) {
		byte b[] = readBytesUntil(interesting);
		if (b == null)
			return null;
		return new String(b);
	}

	private void setAnalogOutput(int ch, int value) {
		if (aoutPortRange.contains(ch)) {
			String s = "a" + Integer.toHexString(ch).toUpperCase();
			value = value < 0 ? 0 : value;
			value = value > 255 ? 255 : value;

			String sv = value < 16 ? "0" : "";
			sv += Integer.toHexString(value).toUpperCase();
			s += sv;
			s += "*";
			write(s);
			aoutCommandQueue.pop(1000);
		} else {
			throw new IndexOutOfBoundsException(
					"Gainer error!! out of bounds analog out");
		}
	}

	private void setAnalogOutput(int[] values) {
		String s = "A";
		String sv = "";
		if (aoutPortRange.getCounts() == values.length) {
			for (int i = 0; i < values.length; i++) {
				values[i] = values[i] < 0 ? 0 : values[i];
				values[i] = values[i] > 255 ? 255 : values[i];
				sv = values[i] < 16 ? "0" : "";
				sv += Integer.toHexString(values[i]).toUpperCase();
				s += sv;
			}
			s += "*";
		} else {
			throw new IndexOutOfBoundsException(
					"Gainer error!! - number of analog outputs are wrong");
		}
		write(s);
		aoutCommandQueue.pop(1000);
	}

	private void setDigitalOutput(boolean[] values) {
		int chs = 0;
		if (doutPortRange.getCounts() == values.length) {
			for (int i = 0; i < values.length; i++) {
				if (values[i]) {
					chs |= (1 << i);
				}
			}
		} else {
			throw new IndexOutOfBoundsException("Out of bounds: dout");
		}
		String val = Integer.toHexString(chs).toUpperCase();
		String sv = "";
		for (int i = 0; i < doutPortRange.getCounts() - val.length(); i++) {
			sv += "0";
		}
		sv += val;

		String s = "D" + sv + "*";
		write(s);
		doutCommandQueue.pop(1000);
	}

	private void setDigitalOutput(int chs) {
		if (chs <= 0xFFFF) {
			String val = Integer.toHexString(chs).toUpperCase();
			String sv = "";
			// ïKÇ∏4åÖ
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
			String s = "H" + Integer.toHexString(ch).toUpperCase() + "*";
			write(s);
			doutCommandQueue.pop(1000);
		} else {
			throw new IndexOutOfBoundsException(
					"Gainer error!! out of bounds digital out");
		}
	}

	private void setDigitalOutputLow(int ch) {
		if (doutPortRange.contains(ch)) {
			String s = "L" + Integer.toHexString(ch).toUpperCase() + "*";
			write(s);
			doutCommandQueue.pop(1000);
		} else {
			throw new IndexOutOfBoundsException(
					"Gainer error!! out of bounds digital out");
		}
	}

	// GAINERに文字列を送る
	private void write(String what) {
		try {
			output.write(what.getBytes());
			output.flush();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}
