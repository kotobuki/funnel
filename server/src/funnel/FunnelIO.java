package funnel;

import java.io.IOException;
import java.util.Hashtable;

import com.illposed.osc.OSCMessage;

import gnu.io.SerialPortEvent;

public class FunnelIO extends FirmataIO implements XBeeEventListener {

	private static final int TOTAL_ANALOG_PINS = 8;
	private static final int TOTAL_DIGITAL_PINS = 10;
	private static final int[] PWM_CAPABLE_PINS = new int[] { 8, 9, 10, 11, 12,
			13, 14, 15 };

	private static final int MAX_IO_PORT = 9;
	private static final int MAX_NODES = 65535;
	private float[][] inputData = new float[MAX_NODES][MAX_IO_PORT];
	private int[] rssi = new int[MAX_NODES];
	private Hashtable nodes;

	private XBee xbee;
	private boolean hasPacket = false;
	private int source = 0;
	private int[] rxData;

	public FunnelIO(FunnelServer server, String serialPortName, int baudRate) {
		super(TOTAL_ANALOG_PINS, TOTAL_DIGITAL_PINS, PWM_CAPABLE_PINS);
		this.parent = server;

		begin(serialPortName, baudRate, 100);

		xbee = new XBee(this, output);
		xbee.sendATCommand("VR");
		xbee.sendATCommand("MY");
		xbee.sendATCommand("ID");
		xbee.sendATCommand("ND");

		nodes = new Hashtable();
	}

	void writeByte(int data) {
		// TODO Auto-generated method stub

	}

	public void firmwareVersionEvent(String version) {
		parent.printMessage(version);
	}

	public void modemStatusEvent(int status) {
		switch (status) {
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
	}

	public void networkingIdentificationEvent(int my, int sh, int sl, int db,
			String ni) {
		String info = "NODE: MY=" + my + ", SH=" + Integer.toHexString(sh)
				+ ", SL=" + Integer.toHexString(sl) + ", dB=" + db + ", NI=\'"
				+ ni + "\'";
		parent.printMessage(info);
		OSCMessage message = new OSCMessage("/node");
		message.addArgument(new Integer(my));
		message.addArgument(new String(ni));
		parent.getNotificationPortServer().sendMessageToClients(message);
		if (nodes.containsKey(new Integer(my))) {
			nodes.remove(new Integer(my));
		}
		nodes.put(new Integer(my), ni);
	}

	public void panIdEvent(String panId) {
		parent.printMessage(panId);
	}

	public void rxIOStatusEvent(int source, int rssi, int ioEnable,
			boolean hasDigitalData, boolean hasAnalogData, int dinStatus,
			float[] analogData) {
		// NOTE: Funnel I/O doesn't use RX_IO_STATUS_16BIT
	}

	public void rxPacketEvent(int source, int rssi, int options, int[] rxData) {
		this.source = source;
		this.rssi[source] = rssi;
		// parent.printMessage(new String("src:" + source + " , rssi:" + rssi
		// + ",data:" + rxData.length));
		// parent.printMessage(new String("ain 0: "));
		// for (int i = 0; i < rxData.length; i++) {
		// processInput(rxData[i]);
		// }
		this.rxData = new int[rxData.length];
		for (int i = 0; i < this.rxData.length; i++) {
			this.rxData[i] = rxData[i];
		}
		hasPacket = true;
	}

	public void sourceAddressEvent(String sourceAddress) {
		parent.printMessage(sourceAddress);
	}

	public void txStatusMessageEvent(int status) {
		switch (status) {
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
	}

	public void unsupportedApiEvent(String apiIdentifier) {
		parent.printMessage(apiIdentifier);
	}

	synchronized public void serialEvent(SerialPortEvent serialEvent) {
		if (serialEvent.getEventType() != SerialPortEvent.DATA_AVAILABLE) {
			return;
		}

		try {
			while (input.available() > 0) {
				int inputData = input.read();
				xbee.processInput(inputData);
			}
		} catch (IOException e) {
			e.printStackTrace();
		}

		if (hasPacket) {
			for (int i = 0; i < this.rxData.length; i++) {
				processInput(this.rxData[i]);
			}
			hasPacket = false;
		}
	}

	private void digitalWrite(int address, int pin, int mode) {
		parent.printMessage("digitalWrite(" + pin + ", " + mode + ")");
		int bitMask = 1 << pin;
		// analog inputs
		int outData = 0;

		if (mode == 1) {
			outData = outData | bitMask;
		}

		byte[] rfData = new byte[3];
		rfData[0] = (byte) (0x90 + 0); // TODO: Support port value to handle
		// more than 14 pins
		rfData[1] = (byte) (outData % 128);
		rfData[2] = (byte) (outData >> 7);

		xbee.sendTransmitRequest(address, rfData);
	}

	private void analogWrite(int address, int pin, float value) {
		int intValue = Math.round(value * 255.0f);
		intValue = (intValue < 0) ? 0 : intValue;
		intValue = (intValue > 255) ? 255 : intValue;

		byte[] rfData = new byte[3];
		rfData[0] = (byte) (0xE0 + pin);
		rfData[1] = (byte) (intValue % 128);
		rfData[2] = (byte) (intValue >> 7);

		xbee.sendTransmitRequest(address, rfData);
	}
}
