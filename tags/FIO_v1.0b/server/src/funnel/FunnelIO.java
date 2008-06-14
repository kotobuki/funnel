package funnel;

import java.io.IOException;
import java.util.Enumeration;
import java.util.Hashtable;

import com.illposed.osc.OSCBundle;
import com.illposed.osc.OSCMessage;

import gnu.io.SerialPortEvent;

public class FunnelIO extends FirmataIO implements XBeeEventListener {

	private static final int TOTAL_ANALOG_PINS = 8;
	private static final int TOTAL_DIGITAL_PINS = 10;
	private static final int[] PWM_CAPABLE_PINS = new int[] { 8, 9, 10, 11, 12,
			13, 14, 15 };

	private static final int MAX_IO_PORT = 18;
	private static final int MAX_NODES = 65535;
	private float[][] inputData = new float[MAX_NODES][MAX_IO_PORT];
	private int[] rssi = new int[MAX_NODES];
	private Hashtable<Integer, String> nodes;

	private XBee xbee;

	public FunnelIO(FunnelServer server, String serialPortName, int baudRate) {
		super(TOTAL_ANALOG_PINS, TOTAL_DIGITAL_PINS, PWM_CAPABLE_PINS);
		this.parent = server;

		begin(serialPortName, baudRate);

		xbee = new XBee(this, output);
		xbee.sendATCommand("VR");
		xbee.sendATCommand("MY");
		xbee.sendATCommand("ID");
		xbee.sendATCommand("ND");

		nodes = new Hashtable<Integer, String>();
	}

	void writeByte(int data) {
		xbee.writeToPacket(data);
	}

	public void firmwareVersionEvent(String version) {
		parent.printMessage(version);
	}

	public void reboot() {
		super.reboot();
		xbee.sendATCommand("ND");
	}

	public void setOutput(Object[] arguments) {
		int moduleId = ((Integer) arguments[0]).intValue();
		int start = ((Integer) arguments[1]).intValue();

		beginPacketIfNeeded(moduleId);
		for (int i = 0; i < (arguments.length - 2); i++) {
			int port = start + i;
			int index = 2 + i;
			if (digitalPinRange.contains(port)) {
				// converts from global pin number to local pin number
				// e.g. global pin number 6 means local pin number 0
				int pin = port - digitalPinRange.getMin();

				if (arguments[index] != null
						&& arguments[index] instanceof Float) {
					if (pinMode[port] == ARD_PIN_MODE_OUT) {
						digitalWrite(pin,
								FLOAT_ZERO.equals(arguments[index]) ? 0 : 1);
					} else if (pinMode[port] == ARD_PIN_MODE_PWM) {
						// analogWrite(pin, ((Float) arguments[index])
						// .floatValue());
					}
				}
			}
		}
		endPacketIfNeeded();
	}

	public OSCBundle getAllInputsAsBundle() {
		if (nodes.isEmpty()) {
			return null;
		}

		OSCBundle bundle = new OSCBundle();
		Enumeration<Integer> e = nodes.keys();

		while (e.hasMoreElements()) {
			Integer id = e.nextElement();
			Object arguments[] = new Object[2 + totalPins];
			arguments[0] = id;
			arguments[1] = new Integer(0);
			for (int i = 0; i < totalPins; i++) {
				arguments[2 + i] = new Float(inputData[id.intValue()][i]);
			}
			bundle.addPacket(new OSCMessage("/in", arguments)); //$NON-NLS-1$
		}

		return bundle;
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

		xbee.beginPacket(my);
		xbee.writeToPacket(0xF9);
		xbee.endPacket();
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
		this.rssi[source] = rssi;
		for (int i = 0; i < rxData.length; i++) {
			processInput(rxData[i]);
		}
		for (int i = 0; i < TOTAL_ANALOG_PINS; i++) {
			this.inputData[source][i] = this.analogData[i];
		}
		for (int i = 0; i < TOTAL_DIGITAL_PINS; i++) {
			this.inputData[source][digitalPinRange.getMin() + i] = this.digitalData[i];
		}
		// printMessage(new String("ain: " + this.inputData[source][0] + ","
		// + this.inputData[source][1]));
		// printMessage(new String("button: " + this.inputData[source][16]));
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
	}

	protected void beginPacketIfNeeded(int destinationId) {
		xbee.beginPacket(destinationId);
	}

	protected void endPacketIfNeeded() {
		xbee.endPacket();
	}
}
