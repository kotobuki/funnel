package funnel;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Enumeration;
import java.util.Hashtable;

import com.illposed.osc.OSCBundle;
import com.illposed.osc.OSCMessage;

import gnu.io.CommPortIdentifier;
import gnu.io.SerialPort;
import gnu.io.SerialPortEvent;
import gnu.io.SerialPortEventListener;

public class XbeeIO extends IOModule implements SerialPortEventListener {
	private static final int FRAME_DELIMITER = 0x7E;
	private static final int ESCAPE = 0x7D;
	private static final int XON = 0x11;
	private static final int XOFF = 0x13;
	private static final int IDX_LENGTH_LSB = 2;
	private static final int IDX_API_IDENTIFIER = 3;
	private static final int IDX_SOURCE_ADDRESS_MSB = 4;
	private static final int IDX_SOURCE_ADDRESS_LSB = 5;
	private static final int IDX_RSSI = 6;
	private static final int IDX_SAMPLES = 8;
	private static final int IDX_IO_ENABLE_MSB = 9;
	private static final int IDX_IO_ENABLE_LSB = 10;
	private static final int IDX_IO_STATUS_START = 11;
	private static final int RX_IO_STATUS_16BIT = 0x83;
	private static final int AT_COMMAND_RESPONSE = 0x88;
	private static final int TX_STATUS_MESSAGE = 0x89;
	private static final int MODEM_STATUS = 0x8A;

	// TODO: update this portion to support XBS2
	private static final int MAX_IO_PORT = 9;

	private static final int MAX_NODES = 65535;
	private static final int MAX_FRAME_SIZE = 100;

	// private final Float FLOAT_ZERO = new Float(0.0f);

	private boolean wasEscaped = false;
	private int rxIndex = 0;
	private int[] rxData = new int[MAX_FRAME_SIZE];
	private int rxBytesToReceive = 0;
	private int rxSum = 0;
	private float[][] inputData = new float[MAX_NODES][MAX_IO_PORT];
	private int[] rssi = new int[MAX_NODES];

	// private funnel.BlockingQueue aoutCommandQueue;

	private SerialPort port;
	private InputStream input;
	private OutputStream output;

	private final int rate = 57600;
	private final int parity = SerialPort.PARITY_NONE;
	private final int databits = 8;
	private final int stopbits = SerialPort.STOPBITS_1;

	private funnel.PortRange dioPortRange;
	private funnel.PortRange pwmPortRange;

	private Hashtable nodes;

	public XbeeIO(FunnelServer server, String serialPortName, int baudRate) {
		this.parent = server;
		parent.printMessage(Messages.getString("IOModule.Starting")); //$NON-NLS-1$
		dioPortRange = new funnel.PortRange();
		dioPortRange.setRange(0, 9); // 8 ports (XBS1), 10 ports (XBS2)
		pwmPortRange = new funnel.PortRange();
		pwmPortRange.setRange(10, 13); // 4 ports
		nodes = new Hashtable();

		// aoutCommandQueue = new funnel.BlockingQueue();

		try {
			Enumeration portList = CommPortIdentifier.getPortIdentifiers();

			while (portList.hasMoreElements()) {
				CommPortIdentifier portId = (CommPortIdentifier) portList
						.nextElement();

				if (portId.getPortType() == CommPortIdentifier.PORT_SERIAL) {
					if (portId.getName().equals(serialPortName)) {
						port = (SerialPort) portId.open("serial xbee", 2000); //$NON-NLS-1$
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
						port
								.setFlowControlMode(SerialPort.FLOWCONTROL_RTSCTS_IN);
						port
								.setFlowControlMode(SerialPort.FLOWCONTROL_RTSCTS_OUT);
						port.addEventListener(this);
						port.notifyOnDataAvailable(true);

						parent.printMessage(Messages
								.getString("IOModule.Started") //$NON-NLS-1$
								+ serialPortName);

						sendATCommand("VR");
						sendATCommand("MY");
						sendATCommand("ID");
						sendATCommand("ND");
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

	public OSCBundle getAllInputsAsBundle() {
		if (nodes.isEmpty()) {
			return null;
		}

		OSCBundle bundle = new OSCBundle();
		Enumeration e = nodes.keys();

		while (e.hasMoreElements()) {
			Integer id = (Integer) e.nextElement();
			Object arguments[] = new Object[2 + MAX_IO_PORT];
			arguments[0] = id;
			arguments[1] = new Integer(0);
			// NOTE: Update here to support XBee ZNet 2.5
			for (int i = 0; i < 8; i++) {	// was "i < MAX_IO_PORT"
				arguments[2 + i] = new Float(inputData[id.intValue()][i]);
			}
			bundle.addPacket(new OSCMessage("/in", arguments)); //$NON-NLS-1$
		}

		return bundle;
	}

	public Object[] getInputs(String address, Object[] arguments) {
		int moduleId = 0;
		int from = 0;
		int counts = 0;
		int totalPortCounts = MAX_IO_PORT;

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
			// TODO
			// modify to handle address request
			results[2 + i] = new Float(inputData[moduleId][i]);
		}
		return results;
	}

	public void reboot() {
		nodes.clear();
		sendATCommand("ND");
		return;
	}

	public void setConfiguration(Object[] arguments) {
		return;
	}

	public void setOutput(Object[] arguments) {
		int moduleId = ((Integer) arguments[0]).intValue();
		int start = ((Integer) arguments[1]).intValue();
		for (int i = 0; i < (arguments.length - 2); i++) {
			int port = start + i;
			int index = 2 + i;
			if (arguments[index] != null && arguments[index] instanceof Float) {
				if (dioPortRange.contains(port)) {
					// digitalWrite(port, FLOAT_ZERO.equals(arguments[index]) ?
					// 0 : 1);
					printMessage("NOT SUPPORTED: DO for " + port);
				} else if (pwmPortRange.contains(port)) {
					analogWrite(moduleId, port, ((Float) arguments[index])
							.floatValue());
				}
			}
		}
		// NOTE: Output side control is not supported in XBee series 1
		// TODO: Implement output control support for XBee series 2
		return;
	}

	public void setPolling(Object[] arguments) {
		return;
	}

	public void startPolling() {
		return;
	}

	public void stopPolling() {
		return;
	}

	synchronized public void serialEvent(SerialPortEvent serialEvent) {
		if (serialEvent.getEventType() != SerialPortEvent.DATA_AVAILABLE) {
			return;
		}

		try {
			while (input.available() > 0) {
				int inputData = input.read();
				if (inputData == FRAME_DELIMITER) {
					rxIndex = 0;
					rxSum = 0;
					wasEscaped = false;
					rxData[rxIndex] = inputData;
				} else if (inputData == ESCAPE) {
					wasEscaped = true;
				} else {
					rxIndex++;
					if (wasEscaped) {
						rxData[rxIndex] = (inputData ^ 0x20);
						wasEscaped = false;
					} else {
						rxData[rxIndex] = inputData;
					}
					if (rxIndex == IDX_LENGTH_LSB) {
						// [START][LENGTH MSB][LENGTH LSB][FRAME DATA][CHECKSUM]
						rxBytesToReceive = (rxData[1] << 8) + rxData[2] + 4;
					} else if (rxIndex == (rxBytesToReceive - 1)) {
						if ((rxSum & 0xFF) + rxData[rxBytesToReceive - 1] == 0xFF) {
							if (false) {
								String s = "DATA:";
								for (int i = 0; i < rxBytesToReceive; i++) {
									s += " " + Integer.toHexString(rxData[i]);
								}
								parent.printMessage(s);
							}
							parseData(rxData, rxBytesToReceive);
						}
					} else if (rxIndex > 2) {
						rxSum += rxData[rxIndex];
					}
				}
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	private void parseData(int[] data, int bytes) {
		switch ((int) data[IDX_API_IDENTIFIER]) {
		case RX_IO_STATUS_16BIT:
			int source = (data[IDX_SOURCE_ADDRESS_MSB] << 8)
					+ data[IDX_SOURCE_ADDRESS_LSB];
			rssi[source] = data[IDX_RSSI] * -1;
			int samples = data[IDX_SAMPLES];
			int ioEnable = (data[IDX_IO_ENABLE_MSB] << 8)
					+ data[IDX_IO_ENABLE_LSB];
			boolean hasDigitalData = (ioEnable & 0x1FF) > 0;
			boolean hasAnalogData = (ioEnable & 0x7E00) > 0;
			int idx = IDX_IO_STATUS_START;
			for (int sample = 0; sample < samples; sample++) {
				if (hasDigitalData) {
					int dinStatus = data[idx] << 8;
					idx++;
					dinStatus += data[idx];
					idx++;
					for (int i = 0; i < MAX_IO_PORT; i++) {
						int bitMask = 1 << i;
						if ((ioEnable & bitMask) != 0) {
							inputData[source][i] = ((dinStatus & bitMask) != 0) ? 1.0f
									: 0.0f;
							// parent.printMessage(new String("DIN" + i + ":"
							// + inputData[source][i]));
						}
					}
				}
				if (hasAnalogData) {
					for (int i = 0; i < 6; i++) {
						// TODO: update here to support XBS2
						int bitMask = 1 << (i + MAX_IO_PORT);

						if ((ioEnable & bitMask) != 0) {
							int ainData = data[idx] << 8;
							idx++;
							ainData += data[idx];
							idx++;
							inputData[source][i] = (float) ainData / 1023.0f;
							// parent.printMessage(new String("AIN" + i + ":"
							// + inputData[source][i]));
						}
					}
				}
			}
			// parent.printMessage(new String("SOURCE:" + source + ", RSSI:"
			// + rssi[source] + "dB"));
			break;
		case AT_COMMAND_RESPONSE:
			// Networking Identification Command (ND)
			if ((data[5] == 'N' && data[6] == 'D') && (bytes > 9)) {
				if (data[7] == 0) {
					// [--MY--][------SH------][------SL------][dB][NI ...
					// [08][09][10][11][12][13][14][15][16][17][18][19]...
					int my = (data[8] << 8) + data[9];
					int sh = data[10] << 24;
					sh += data[11] << 16;
					sh += data[12] << 8;
					sh += data[13];
					int sl = data[14] << 24;
					sl += data[15] << 16;
					sl += data[16] << 8;
					sl += data[17];
					int db = data[18];
					byte[] nibytes = new byte[20];
					int count = 0;
					for (int i = 0; i < 20; i++) {
						if (data[19 + i] == 0) {
							break;
						} else {
							nibytes[i] = (byte) data[19 + i];
							count++;
						}
					}
					String ni = new String(nibytes, 0, count);
					String info = "NODE: MY=" + my + ", SH="
							+ Integer.toHexString(sh) + ", SL="
							+ Integer.toHexString(sl) + ", dB=" + db
							+ ", NI=\'" + ni + "\'";
					parent.printMessage(info);
					OSCMessage message = new OSCMessage("/node");
					message.addArgument(new Integer(my));
					message.addArgument(new String(ni));
					parent.getNotificationPortServer().sendMessageToClients(
							message);
					if (nodes.containsKey(new Integer(my))) {
						nodes.remove(new Integer(my));
					}
					nodes.put(new Integer(my), ni);
				}
			} else if (data[5] == 'V' && data[6] == 'R') {
				String info = "FIRMWARE VERSION: ";
				info += Integer.toHexString(data[8]);
				info += Integer.toHexString(data[9]);
				parent.printMessage(info);
			} else if (data[5] == 'M' && data[6] == 'Y') {
				String info = "SOURCE ADDRESS: ";
				info += Integer.toHexString(data[8]);
				info += Integer.toHexString(data[9]);
				parent.printMessage(info);
			} else if (data[5] == 'I' && data[6] == 'D') {
				String info = "PAN ID: ";
				info += Integer.toHexString(data[8]);
				info += Integer.toHexString(data[9]);
				parent.printMessage(info);
			}
			break;
		case TX_STATUS_MESSAGE:
			// {0x7E}+{0x00+0x03}+{0x89}+{Frame ID}+{Status}+{Checksum}
			switch (data[IDX_API_IDENTIFIER + 2]) {
			// case 0x00:
			// parent.printMessage("TX Status: ACK");
			// break;
			case 0x01:
				parent.printMessage("TX Status: No ACK");
				break;
			case 0x02:
				parent.printMessage("TX Status: CCA failure");
				break;
			case 0x03:
				parent.printMessage("TX Status: Purged");
				break;
			default:
				break;
			}
			// aoutCommandQueue.push(new Integer(data[IDX_API_IDENTIFIER + 2]));
			break;
		case MODEM_STATUS:
			// {0x7E}+{0x00+0x02}+{0x8A}+{cmdData}+{sum}
			switch (data[IDX_API_IDENTIFIER + 1]) {
			case 0x00:
				parent.printMessage("Modem Status: Hardware reset");
				break;
			case 0x01:
				parent.printMessage("Modem Status: Watchdog timer reset");
				break;
			case 0x02:
				parent.printMessage("Modem Status: Associated");
				break;
			case 0x03:
				parent.printMessage("Modem Status: Disassociated");
				break;
			case 0x04:
				parent.printMessage("Modem Status: Synchronization Lost");
				break;
			case 0x05:
				parent.printMessage("Modem Status: Coordinator realignment");
				break;
			case 0x06:
				parent.printMessage("Modem Status: Coordinator started");
				break;
			default:
				break;
			}
			break;
		default:
			String s = "UNSUPPORTED API: ";
			s += Integer.toHexString(data[IDX_API_IDENTIFIER]);
			parent.printMessage(s);
			break;
		}
	}

	// private void digitalWrite(int pin, int mode) {
	// // parent.printMessage("digitalWrite(" + pin + ", " + mode + ")");
	// int bitMask = 1 << pin;
	// int outData = 0;
	//
	// if (mode == 1) {
	// outData = 1 << pin;
	// }
	//
	// byte[] rfData = new byte[14];
	// rfData[0] = 0x7E; // Frame Delimiter
	// rfData[1] = 0x00; // Length MSB
	// rfData[2] = 0x0A; // Length LSB
	// rfData[3] = (byte) 0x83; // API ID
	// rfData[4] = 0x00; // Source Address MSB
	// rfData[5] = 0x01; // Source Address LSB
	// rfData[6] = 0x20; // RSSI
	// rfData[7] = 0x00; // Options
	// rfData[8] = 0x01; // Samples
	// rfData[9] = (byte) (bitMask >> 8); // I/O Enable MSB
	// rfData[10] = (byte) (bitMask & 0xFF); // I/O Enable LSB
	// rfData[11] = (byte) (outData >> 8); // I/O Status MSB
	// rfData[12] = (byte) (outData & 0xFF); // I/O Status LSB
	// int sum = 0;
	// for (int i = 3; i < 13; i++) {
	// sum += rfData[i];
	// }
	// rfData[13] = (byte) (0xFF - (sum & 0xFF));
	// }

	private void analogWrite(int address, int pin, float value) {
		// parent.printMessage("analogWrite(" + pin + ", " + value + ")");
		// int intValue = Math.round(value * 1023.0f);
		// intValue = (intValue < 0) ? 0 : intValue;
		// intValue = (intValue > 1023) ? 1023 : intValue;

		// byte[] rfData = new byte[12];
		// rfData[0] = 0x7E; // Frame Delimiter
		// rfData[1] = 0x00; // Length MSB
		// rfData[2] = 0x08; // Length LSB
		// rfData[3] = (byte) 0x08; // API ID
		// rfData[4] = 0x01; // Frame ID
		// rfData[5] = 'M'; // Source Address LSB
		// rfData[6] = '0'; // RSSI
		// rfData[7] = '0'; // Options
		// rfData[8] = '3'; // Options
		// rfData[9] = 'F'; // Samples
		// rfData[10] = 'F'; // I/O Enable MSB
		// int sum = 0;
		// for (int i = 3; i < 11; i++) {
		// sum += rfData[i];
		// }
		// rfData[11] = (byte) (0xFF - (sum & 0xFF));

		int intValue = Math.round(value * 255.0f);
		intValue = (intValue < 0) ? 0 : intValue;
		intValue = (intValue > 255) ? 255 : intValue;

		byte[] rfData = new byte[3];
		rfData[0] = (byte) (0xE0 + pin);
		rfData[1] = (byte) (intValue % 128);
		rfData[2] = (byte) (intValue >> 7);

		sendTransmitRequest(address, rfData);
	}

	private void sendATCommand(String command) {
		byte[] outData = new byte[2 + command.length()];
		outData[0] = 0x08; // AT Command
		outData[1] = 0x01; // Frame ID
		for (int i = 0; i < command.length(); i++) {
			outData[2 + i] = (byte) command.charAt(i);
		}
		sendCommand(outData);
	}

	private void sendTransmitRequest(int destAddress, byte[] rfData) {
		byte[] outData = new byte[5 + rfData.length];
		outData[0] = 0x01; // Transmit Request
		outData[1] = 0x00; // Frame ID (0x00 means no ACK)
		outData[2] = (byte) (destAddress >> 8);
		outData[3] = (byte) (destAddress & 0xFF);
		outData[4] = 0x01; // Options (0x00: with ACK, 0x01: without ACK)
		for (int i = 0; i < rfData.length; i++) {
			outData[5 + i] = rfData[i];
		}
		sendCommand(outData);
		// aoutCommandQueue.pop(50);
	}

	private void sendCommand(byte[] frameData) {
		byte[] outData = new byte[128];
		int sum = 0;
		int length = 0;
		int escaped = 0;

		for (int idx = 0; idx < frameData.length; idx++) {
			switch (frameData[idx]) {
			case FRAME_DELIMITER:
			case ESCAPE:
			case XON:
			case XOFF:
				outData[3 + length] = ESCAPE;
				length++;
				outData[3 + length] = (byte) (frameData[idx] ^ 0x20);
				length++;
				escaped++;
				break;
			default:
				outData[3 + length] = frameData[idx];
				length++;
				break;
			}
			sum += frameData[idx];
		}
		outData[0] = 0x7E; // FRAME_DELIMITER
		outData[1] = 0x00; // Length (MSB)
		outData[2] = (byte) (length - escaped); // Length (LSB)
		outData[3 + length] = (byte) (0xFF - (sum & 0xFF)); // Checksum
		try {
			output.write(outData);
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
}
