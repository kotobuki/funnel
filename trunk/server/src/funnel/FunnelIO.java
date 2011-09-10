package funnel;

import java.io.IOException;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

import com.illposed.osc.OSCMessage;

import gnu.io.SerialPortEvent;

public class FunnelIO extends FirmataIO implements XBeeEventListener {
	class NodeDiscoveryTask implements Runnable {
		NodeDiscoveryTask(FunnelServer server, XBee xbee) {
			this.server = server;
			this.xbee = xbee;
		}

		public void run() {
			xbee.sendATCommand("ND");
			server.printMessage("Discovering nodes...");
		}

		private FunnelServer server;
		private XBee xbee;
	}

	private static final int TOTAL_ANALOG_PINS = 8;
	private static final int TOTAL_DIGITAL_PINS = 22;
	private static final int[] PWM_CAPABLE_PINS = new int[] {
		3, 5, 6, 9, 10, 11
	};

	private int[] rssi = new int[MAX_NODES];
	private Hashtable<Integer, String> nodes;

	private XBee xbee;
	private Runnable nodeDiscoveryTask;
	private ScheduledExecutorService scheduler;

	public FunnelIO(FunnelServer server, String serialPortName, int baudRate) {
		super(TOTAL_ANALOG_PINS, TOTAL_DIGITAL_PINS, PWM_CAPABLE_PINS);
		this.parent = server;
		this.baudRate = baudRate;

		begin(serialPortName, baudRate);
		byte[] command = new byte[] {
				'+', '+', '+'
		};
		byte[] apiModeCommand = new byte[] {
				'A', 'T', 'A', 'P', '2', ',', ' ', 'C', 'N', 13
		};
		try {
			output.write(command);
			sleep(1500);
			output.write(apiModeCommand);
			sleep(100);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		xbee = new XBee(this, output);
		xbee.sendATCommand("AP");
		xbee.sendATCommand("VR");
		xbee.sendATCommand("ID");
		xbee.sendATCommand("MY");

		nodes = new Hashtable<Integer, String>();

		nodeDiscoveryTask = new NodeDiscoveryTask(parent, xbee);
		scheduler = Executors.newSingleThreadScheduledExecutor();
		scheduler.schedule(nodeDiscoveryTask, 1, TimeUnit.SECONDS);
		scheduler.schedule(nodeDiscoveryTask, 4, TimeUnit.SECONDS);
		scheduler.schedule(nodeDiscoveryTask, 7, TimeUnit.SECONDS);
	}

	void writeByte(int data) {
		xbee.writeToPacket(data);
	}

	public void firmwareVersionEvent(String version) {
		parent.printMessage(version);
	}

	public void reboot() {
		return;
	}

	public void dispose() {
		if (xbee != null) {
			printMessage("Reverteing the API mode setting to 0"); //$NON-NLS-1$
			byte[] command = new byte[] {
					'+', '+', '+'
			};
			byte[] apiModeCommand = new byte[] {
					'A', 'T', 'A', 'P', '0', ',', ' ', 'C', 'N', 13
			};
			try {
				output.write(command);
				sleep(1500);
				output.write(apiModeCommand);
				sleep(100);
				System.out.println("reverted the API mode setting to 0");
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		super.dispose();
	}

	public void setConfiguration(Object[] arguments) {
		super.setConfiguration(arguments);

		Enumeration<Integer> e = nodes.keys();
		while (e.hasMoreElements()) {
			Integer moduleId = e.nextElement();
			for (int j = 0; j < dinPinChunks.size(); j++) {
				PortRange range = dinPinChunks.get(j);
				notifyUpdate(moduleId, range.getMin(), range.getCounts());
			}
		}
	}

	public void setOutput(Object[] arguments) {
		int moduleId = ((Integer) arguments[0]).intValue();
		int start = ((Integer) arguments[1]).intValue();
		beginPacketIfNeeded(moduleId);
		for (int i = 0; i < (arguments.length - 2); i++) {
			int port = start + i;
			int index = 2 + i;
			if (digitalPins.indexOf(port) >= 0) {
				// converts from global pin number to local pin number
				// e.g. global pin number 8 means local pin number 0
				int pin = port - digitalPins.get(0);

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
		String info = "NODE: MY=" + my + ", SH=" + Integer.toHexString(sh) + ", SL=" + Integer.toHexString(sl) + ", dB=" + db + ", NI=\'" + ni + "\'";

		OSCMessage message = new OSCMessage("/node");
		message.addArgument(new Integer(my));
		message.addArgument(new String(ni));
		parent.getCommandPortServer().sendMessageToClients(message);

		if (!nodes.containsKey(new Integer(my))) {
			nodes.put(new Integer(my), ni);
			parent.printMessage(info);
			xbee.beginPacket(my);
			xbee.writeToPacket(0xF9);
			xbee.endPacket();
		}
	}

	public void panIdEvent(String panId) {
		parent.printMessage(panId);
	}

	public void apiModeEvent(String apiMode) {
		parent.printMessage(apiMode);
	}

	public void rxIOStatusEvent(int source, int rssi, float[] inData) {
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

	public void stringMessageEvent(String errorMessage) {
		parent.printMessage(errorMessage);
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
