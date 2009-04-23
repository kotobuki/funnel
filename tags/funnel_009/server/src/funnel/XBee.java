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
	private static final int IDX_ZB_16BIT_ADDRESS_MSB = 12;
	private static final int IDX_ZB_16BIT_ADDRESS_LSB = 13;
	// private static final int IDX_ZB_OPTIONS = 14;
	private static final int IDX_ZB_SAMPLES = 15;
	private static final int IDX_ZB_DIGITAL_CH_MASK_MSB = 16;
	private static final int IDX_ZB_DIGITAL_CH_MASK_LSB = 17;
	private static final int IDX_ZB_ANALOG_CH_MASK = 18;
	private static final int IDX_ZB_IO_STATUS_START = 19;
	// private static final int IDX_PACKET_RF_DATA = 8;
	private static final int RX_PACKET_16BIT = 0x81;
	private static final int RX_IO_STATUS_16BIT = 0x83;
	private static final int AT_COMMAND_RESPONSE = 0x88;
	private static final int TX_STATUS_MESSAGE = 0x89;
	private static final int MODEM_STATUS = 0x8A;
	private static final int RX_IO_STATUS_ZB = 0x92;
	// private static final int NODE_IDENTIFICATION = 0x95;
	private static final int REMOTE_COMMAND_RESPONSE = 0x97;
	private static final int MAX_FRAME_SIZE = 100;

	private static final int XBEE_MULTIPOINT_MAX_IO_PORT = 9;

	XBeeEventListener listener;
	private OutputStream output;

	private boolean wasEscaped = false;
	private int rxIndex = 0;
	private int[] rxData = new int[MAX_FRAME_SIZE];
	private int rxBytesToReceive = 0;
	private int rxSum = 0;

	private int txDestAddress = 0xFFFF;
	private byte[] txData = new byte[MAX_FRAME_SIZE];
	private int txDataIdx = 0;

	private boolean isZigBeeModel = true;
	private long[] destinationAddress = new long[65536];

	public XBee(XBeeEventListener listener, OutputStream output) {
		this.listener = listener;
		this.output = output;
		for (int i = 0; i < destinationAddress.length; i++) {
			destinationAddress[i] = 0;
		}
		destinationAddress[0xFFFF] = 0x000000000000FFFFL;
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
					parseData(rxData, rxBytesToReceive);
				}
			} else if (rxIndex > 2) {
				rxSum += rxData[rxIndex];
			}
		}
	}

	public void setDIOConfiguration(int networkAddress, int number, int mode) {
		if (destinationAddress[networkAddress] == 0) {
			listener.stringMessageEvent("ERROR: Unregistered network address (" + networkAddress
					+ ")");
			return;
		}

		if (isZigBeeModel) {
			switch (number) {
			case 0:
			case 1:
			case 2:
			case 3:
			case 4:
			case 5:
			case 7:
				sendRemoteATCommand(destinationAddress[networkAddress], "D"
						+ Integer.toString(number), new byte[] { (byte) mode });
				break;
			case 10:
			case 11:
			case 12:
				sendRemoteATCommand(destinationAddress[networkAddress], "P"
						+ Integer.toString(number - 10), new byte[] { (byte) mode });
				break;
			default:
				break;
			}
		} else {
			switch (number) {
			case 0:
			case 1:
			case 2:
			case 3:
			case 4:
			case 5:
			case 6:
			case 7:
				sendRemoteATCommand(destinationAddress[networkAddress], "D"
						+ Integer.toString(number), new byte[] { (byte) mode });
				break;
			default:
				break;
			}
		}
	}

	private void parseData(int[] data, int bytes) {
		switch ((int) data[IDX_API_IDENTIFIER]) {
		case RX_PACKET_16BIT: {
			// {Source (MSB)}+{Source (LSB)}+{RSSI}+{Options}+{RF Data}
			int source = (data[IDX_SOURCE_ADDRESS_MSB] << 8) + data[IDX_SOURCE_ADDRESS_LSB];
			int rssi = data[IDX_RSSI] * -1;
			int options = data[IDX_PACKET_OPTIONS];
			int[] rxData = new int[bytes - 9];
			for (int i = 0; i < rxData.length; i++) {
				rxData[i] = data[i + 8];
			}
			listener.rxPacketEvent(source, rssi, options, rxData);
		}
			break;
		case RX_IO_STATUS_16BIT: {
			int source = (data[IDX_SOURCE_ADDRESS_MSB] << 8) + data[IDX_SOURCE_ADDRESS_LSB];
			int rssi = data[IDX_RSSI] * -1;
			int samples = data[IDX_SAMPLES];
			int ioEnable = (data[IDX_IO_ENABLE_MSB] << 8) + data[IDX_IO_ENABLE_LSB];
			boolean hasDigitalData = (ioEnable & 0x1FF) > 0;
			boolean hasAnalogData = (ioEnable & 0x7E00) > 0;
			int idx = IDX_IO_STATUS_START;

			for (int sample = 0; sample < samples; sample++) {
				int dinStatus = 0x0000;
				float[] inputData = { -1, -1, -1, -1, -1, -1, -1, -1 };

				if (hasDigitalData) {
					dinStatus = data[idx] << 8;
					idx++;
					dinStatus += data[idx];
					idx++;
					for (int i = 0; i < inputData.length; i++) {
						int bitMask = 1 << i;
						if ((ioEnable & bitMask) != 0) {
							inputData[i] = ((dinStatus & bitMask) != 0) ? 1.0f : 0.0f;
						}
					}
				}
				if (hasAnalogData) {
					for (int i = 0; i < 6; i++) {
						int bitMask = 1 << (i + XBEE_MULTIPOINT_MAX_IO_PORT);

						if ((ioEnable & bitMask) != 0) {
							int ainData = data[idx] << 8;
							idx++;
							ainData += data[idx];
							idx++;
							inputData[i] = (float) ainData / 1023.0f;
						}
					}
				}
				listener.rxIOStatusEvent(source, rssi, inputData);
			}
		}
			break;
		case RX_IO_STATUS_ZB: {
			int source = (data[IDX_ZB_16BIT_ADDRESS_MSB] << 8) + data[IDX_ZB_16BIT_ADDRESS_LSB];
			int rssi = 0;
			// int options = data[IDX_ZNET_OPTIONS];
			int samples = data[IDX_ZB_SAMPLES];
			int digitalChannelMask = (data[IDX_ZB_DIGITAL_CH_MASK_MSB] << 8)
					+ data[IDX_ZB_DIGITAL_CH_MASK_LSB];
			int analogChannelMask = data[IDX_ZB_ANALOG_CH_MASK];
			boolean hasDigitalData = (digitalChannelMask & 0x1FFF) > 0;
			boolean hasAnalogData = (analogChannelMask & 0x0F) > 0;
			int idx = IDX_ZB_IO_STATUS_START;

			for (int sample = 0; sample < samples; sample++) {
				int dinStatus = 0x0000;
				float[] inputData = { -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 };

				if (hasDigitalData) {
					dinStatus = data[idx] << 8;
					idx++;
					dinStatus += data[idx];
					idx++;
					for (int i = 0; i < 13; i++) {
						int bitMask = 1 << i;

						if ((digitalChannelMask & bitMask) != 0) {
							inputData[i] = ((dinStatus & bitMask) != 0) ? 1.0f : 0.0f;
						}
					}
				}
				if (hasAnalogData) {
					for (int i = 0; i < 4; i++) {
						int bitMask = 1 << i;

						if ((analogChannelMask & bitMask) != 0) {
							int ainData = data[idx] << 8;
							idx++;
							ainData += data[idx];
							idx++;
							inputData[i] = (float) ainData / 1023.0f;
						}
					}
				}
				listener.rxIOStatusEvent(source, rssi, inputData);
			}
		}
			break;
		case AT_COMMAND_RESPONSE:
			// Networking Identification Command (ND)
			if ((data[5] == 'N' && data[6] == 'D') && (bytes > 9)) {
				if (!isZigBeeModel) {
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
						destinationAddress[my] = ((long) sh << 32) + (long) sl;
						int db = data[18];

						int count = 0;
						for (int i = 0; i < 20; i++) {
							if (data[19 + i] == 0) {
								break;
							} else {
								count++;
							}
						}
						String ni = new String(data, 19, count);
						listener.networkingIdentificationEvent(my, sh, sl, db, ni);
					}
				} else {
					if (data[7] == 0) {
						// [--MY--][------SH------][------SL------][NI ...
						// [08][09][10][11][12][13][14][15][16][17][18]...
						// 
						// [Parent Network Address][Device Type]
						int idx = 8;
						int my = (data[idx++] << 8) + data[idx++];
						int sh = data[idx++] << 24;
						sh += data[idx++] << 16;
						sh += data[idx++] << 8;
						sh += data[idx++];
						int sl = data[idx++] << 24;
						sl += data[idx++] << 16;
						sl += data[idx++] << 8;
						sl += data[idx++];
						destinationAddress[my] = ((long) sh << 32) + (long) sl;

						int count = 0;
						for (int i = 0; i < 20; i++) {
							int c = data[idx++];
							if (c == 0) {
								break;
							} else {
								count++;
							}
						}
						String ni = new String(data, 18, count);

						int parentNetworkAddress = data[idx++] << 8;
						parentNetworkAddress += data[idx++];
						int deviceType = data[idx++];
						switch (deviceType) {
						case 0:
							ni += " (coordinator)";
							break;
						case 1:
							ni += " (router)";
							break;
						case 2:
							ni += " (end device)";
							break;
						}

						listener.networkingIdentificationEvent(my, sh, sl, 0, ni);
					}
				}
			} else if (data[5] == 'V' && data[6] == 'R') {
				String info = "FIRMWARE VERSION: ";
				info += Integer.toHexString(data[8]).toUpperCase();
				info += Integer.toHexString(data[9]).toUpperCase();
				if ((data[8] >> 4) == 2) {
					info += " (XBee ZB ZigBee PRO or ZNet 2.5)";
					isZigBeeModel = true;
				} else {
					info += " (XBee 802.15.4)";
					isZigBeeModel = false;
				}
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
			} else if (data[5] == 'A' && data[6] == 'P') {
				String info = "API MODE: ";
				info += Integer.toHexString(data[8]);
				// info += Integer.toHexString(data[9]);
				listener.apiModeEvent(info);
			}
			break;
		case REMOTE_COMMAND_RESPONSE:
			if (data[17] != 0) {
				String response = "ERROR: REMOTE COMMAND RESPONSE: ";
				response += Integer.toHexString(data[17]);
				listener.stringMessageEvent(response);
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

	public void beginPacket(int destAddress) {
		txDestAddress = destAddress;
		txDataIdx = 0;
	}

	public void writeToPacket(int data) {
		txData[txDataIdx] = (byte) data;
		txDataIdx++;
		if (txDataIdx >= (MAX_FRAME_SIZE - 1)) {
			sendTransmitRequest(txDestAddress, txData, txDataIdx);
			txDataIdx = 0;
		}
	}

	public void endPacket() {
		sendTransmitRequest(txDestAddress, txData, txDataIdx);
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

	public void sendRemoteATCommand(long destAddress, String commandName, byte[] commandData) {
		// System.out.println("dest: " + Long.toHexString(destAddress) +
		// commandName + commandData[0]);
		byte[] outData = new byte[13 + commandName.length() + commandData.length];
		outData[0] = (byte) 0x17; // Remote AT Command Request
		outData[1] = (byte) 0x01; // Frame ID
		outData[2] = (byte) (destAddress >> 56);
		outData[3] = (byte) (destAddress >> 48);
		outData[4] = (byte) (destAddress >> 40);
		outData[5] = (byte) (destAddress >> 32);
		outData[6] = (byte) (destAddress >> 24);
		outData[7] = (byte) (destAddress >> 16);
		outData[8] = (byte) (destAddress >> 8);
		outData[9] = (byte) (destAddress & 0xFF);
		outData[10] = (byte) 0xFF;
		outData[11] = (byte) 0xFE;
		outData[12] = (byte) 0x02; // Apply changes on remote
		for (int i = 0; i < commandName.length(); i++) {
			outData[13 + i] = (byte) commandName.charAt(i);
		}
		for (int i = 0; i < commandData.length; i++) {
			outData[13 + commandName.length() + i] = commandData[i];
		}
		sendCommand(outData);
	}

	public void sendTransmitRequest(int destAddress, byte[] rfData, int rfDataLength) {
		byte[] outData = new byte[5 + rfDataLength];
		outData[0] = 0x01; // Transmit Request
		outData[1] = 0x00; // Frame ID (0x00 means no ACK)
		outData[2] = (byte) (destAddress >> 8);
		outData[3] = (byte) (destAddress & 0xFF);
		outData[4] = 0x01; // Options (0x00: with ACK, 0x01: without ACK)
		for (int i = 0; i < rfDataLength; i++) {
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
			output.write(outData, 0, length + 4);
			output.flush();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
}
