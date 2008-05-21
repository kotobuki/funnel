package funnel;

import java.io.IOException;
import java.io.OutputStream;

public class XBee {
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
	private static final int IDX_PACKET_OPTIONS = 7;
	// private static final int IDX_PACKET_RF_DATA = 8;
	private static final int RX_PACKET_16BIT = 0x81;
	private static final int RX_IO_STATUS_16BIT = 0x83;
	private static final int AT_COMMAND_RESPONSE = 0x88;
	private static final int TX_STATUS_MESSAGE = 0x89;
	private static final int MODEM_STATUS = 0x8A;
	private static final int MAX_FRAME_SIZE = 100;

	// TODO: update this portion to support XBS2
	private static final int MAX_IO_PORT = 9;

	XBeeEventListener listener;
	private OutputStream output;

	private boolean wasEscaped = false;
	private int rxIndex = 0;
	private int[] rxData = new int[MAX_FRAME_SIZE];
	private int rxBytesToReceive = 0;
	private int rxSum = 0;

	public XBee(XBeeEventListener listener, OutputStream output) {
		this.listener = listener;
		this.output = output;
	}

	public void processInput(int inputData) {
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
					// if (false) {
					// String s = "DATA:";
					// for (int i = 0; i < rxBytesToReceive; i++) {
					// s += " " + Integer.toHexString(rxData[i]);
					// }
					// parent.printMessage(s);
					// }
					parseData(rxData, rxBytesToReceive);
				}
			} else if (rxIndex > 2) {
				rxSum += rxData[rxIndex];
			}
		}
	}

	private void parseData(int[] data, int bytes) {
		switch ((int) data[IDX_API_IDENTIFIER]) {
		case RX_PACKET_16BIT: {
			// {Source Address(MSB)}+{Source Address: LSB}+{RSSI}+{Options}+{RF
			// Data}
			int source = (data[IDX_SOURCE_ADDRESS_MSB] << 8)
					+ data[IDX_SOURCE_ADDRESS_LSB];
			int rssi = data[IDX_RSSI] * -1;
			int options = data[IDX_PACKET_OPTIONS];
			listener.rxPacketEvent(source, rssi, options, data);
		}
			break;
		case RX_IO_STATUS_16BIT: {
			int source = (data[IDX_SOURCE_ADDRESS_MSB] << 8)
					+ data[IDX_SOURCE_ADDRESS_LSB];
			int rssi = data[IDX_RSSI] * -1;
			int samples = data[IDX_SAMPLES];
			int ioEnable = (data[IDX_IO_ENABLE_MSB] << 8)
					+ data[IDX_IO_ENABLE_LSB];
			boolean hasDigitalData = (ioEnable & 0x1FF) > 0;
			boolean hasAnalogData = (ioEnable & 0x7E00) > 0;
			int idx = IDX_IO_STATUS_START;
			int dinStatus = 0x0000;
			float[] analogData = new float[6];
			for (int sample = 0; sample < samples; sample++) {
				if (hasDigitalData) {
					dinStatus = data[idx] << 8;
					idx++;
					dinStatus += data[idx];
					idx++;
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
							analogData[i] = (float) ainData / 1023.0f;
							// parent.printMessage(new String("AIN" + i + ":"
							// + inputData[source][i]));
						}
					}
				}
			}
			listener.rxIOStatusEvent(source, rssi, ioEnable, hasDigitalData,
					hasAnalogData, dinStatus, analogData);
			// parent.printMessage(new String("SOURCE:" + source + ", RSSI:"
			// + rssi[source] + "dB"));
		}
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
					listener.networkingIdentificationEvent(my, sh, sl, db, ni);
				}
			} else if (data[5] == 'V' && data[6] == 'R') {
				String info = "FIRMWARE VERSION: ";
				info += Integer.toHexString(data[8]);
				info += Integer.toHexString(data[9]);
				listener.firmwareVersionEvent(info);
			} else if (data[5] == 'M' && data[6] == 'Y') {
				String info = "SOURCE ADDRESS: ";
				info += Integer.toHexString(data[8]);
				info += Integer.toHexString(data[9]);
				listener.sourceAddressEvent(info);
			} else if (data[5] == 'I' && data[6] == 'D') {
				String info = "PAN ID: ";
				info += Integer.toHexString(data[8]);
				info += Integer.toHexString(data[9]);
				listener.panIdEvent(info);
			}
			break;
		case TX_STATUS_MESSAGE:
			// {0x7E}+{0x00+0x03}+{0x89}+{Frame ID}+{Status}+{Checksum}
			listener.txStatusMessageEvent(data[IDX_API_IDENTIFIER + 2]);
			break;
		case MODEM_STATUS:
			// {0x7E}+{0x00+0x02}+{0x8A}+{cmdData}+{sum}
			listener.modemStatusEvent(data[IDX_API_IDENTIFIER + 1]);
			break;
		default:
			String apiIdentifier = "UNSUPPORTED API: ";
			apiIdentifier += Integer.toHexString(data[IDX_API_IDENTIFIER]);
			listener.unsupportedApiEvent(apiIdentifier);
			break;
		}
	}

	public void sendATCommand(String command) {
		byte[] outData = new byte[2 + command.length()];
		outData[0] = 0x08; // AT Command
		outData[1] = 0x01; // Frame ID
		for (int i = 0; i < command.length(); i++) {
			outData[2 + i] = (byte) command.charAt(i);
		}
		sendCommand(outData);
	}

	public void sendTransmitRequest(int destAddress, byte[] rfData) {
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
