package funnel;

import java.io.IOException;
import java.util.Hashtable;

import com.illposed.osc.OSCMessage;

import gnu.io.SerialPortEvent;

public class FunnelIO extends FirmataIO implements XBeeEventListener {

	private static final int TOTAL_ANALOG_PINS = 8;
	private static final int TOTAL_DIGITAL_PINS = 14;
	private static final int[] PWM_CAPABLE_PINS = new int[] { 11, 13, 14, 17, 18, 19 };

	private int[] rssi = new int[MAX_NODES];
	private Hashtable<Integer, String> nodes;

	private XBee xbee;

	public FunnelIO(FunnelServer server, String serialPortName, int baudRate) {
		super(TOTAL_ANALOG_PINS, TOTAL_DIGITAL_PINS, PWM_CAPABLE_PINS);
		this.parent = server;

		begin(serialPortName, baudRate);
		byte[] command = new byte[] { '+', '+', '+' };
		byte[] apiModeCommand = new byte[] { 'A', 'T', 'A', 'P', '2', ',', ' ', 'C', 'N', 13 };
		try {
			output.write(command);
			sleep(1500);
			output.write(apiModeCommand);
			sleep(100);
			parent.printMessage("XBee API Mode: 2");
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		// // TODO: Replace following with a proper implementation
		// for (int i = 0; i < analogPinRange.getCounts(); i++) {
		// pinMode[i + analogPinRange.getMin()] = ARD_PIN_MODE_AIN;
		// }
		// for (int i = 0; i < digitalPinRange.getCounts(); i++) {
		// pinMode[i + digitalPinRange.getMin()] = ARD_PIN_MODE_OUT;
		// }
		// pinMode[3 + digitalPinRange.getMin()] = ARD_PIN_MODE_PWM;
		// pinMode[10 + digitalPinRange.getMin()] = ARD_PIN_MODE_PWM;
		// pinMode[11 + digitalPinRange.getMin()] = ARD_PIN_MODE_PWM;
		// pinMode[5 + digitalPinRange.getMin()] = ARD_PIN_MODE_PWM;

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
				// e.g. global pin number 8 means local pin number 0
				int pin = port - digitalPinRange.getMin();

				if (arguments[index] != null && arguments[index] instanceof Float) {
					if (pinMode[port] == ARD_PIN_MODE_OUT) {
						digitalWrite(pin, FLOAT_ZERO.equals(arguments[index]) ? 0 : 1);
					} else if (pinMode[port] == ARD_PIN_MODE_PWM) {
						analogWrite(pin, ((Float) arguments[index]).floatValue());
					}
				}
			}
		}
		endPacketIfNeeded();
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

	public void networkingIdentificationEvent(int my, int sh, int sl, int db, String ni) {
		String info = "NODE: MY=" + my + ", SH=" + Integer.toHexString(sh) + ", SL="
				+ Integer.toHexString(sl) + ", dB=" + db + ", NI=\'" + ni + "\'";
		parent.printMessage(info);
		OSCMessage message = new OSCMessage("/node");
		message.addArgument(new Integer(my));
		message.addArgument(new String(ni));
		parent.getCommandPortServer().sendMessageToClients(message);
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

	public void rxIOStatusEvent(int source, int rssi, int ioEnable, boolean hasDigitalData,
			boolean hasAnalogData, int dinStatus, float[] analogData) {
		// NOTE: Funnel I/O doesn't use RX_IO_STATUS_16BIT
	}

	public void rxPacketEvent(int source, int rssi, int options, int[] rxData) {
		this.rssi[source] = rssi;
		for (int i = 0; i < rxData.length; i++) {
			processInput(source, rxData[i]);
		}
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
