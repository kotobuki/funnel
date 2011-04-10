package funnel;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

import com.illposed.osc.OSCMessage;

import gnu.io.CommPortIdentifier;
import gnu.io.SerialPort;
import gnu.io.SerialPortEvent;
import gnu.io.SerialPortEventListener;

public class XbeeIO extends IOModule implements SerialPortEventListener, XBeeEventListener {
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

	private static final int MAX_IO_PORT = 13;
	private static final int MAX_NODES = 65536;

	private float[][] inputData = new float[MAX_NODES][MAX_IO_PORT];
	private int[] rssi = new int[MAX_NODES];

	private SerialPort port;
	private InputStream input;
	private OutputStream output;

	private final int rate = 57600;
	private final int parity = SerialPort.PARITY_NONE;
	private final int databits = 8;
	private final int stopbits = SerialPort.STOPBITS_1;

	private Hashtable<Integer, String> nodes;
	private XBee xbee;

	private Runnable nodeDiscoveryTask;
	private ScheduledExecutorService scheduler;

	public XbeeIO(FunnelServer server, String serialPortName, int baudRate) {
		this.parent = server;
		this.baudRate = baudRate;

		parent.printMessage(Messages.getString("IOModule.Starting")); //$NON-NLS-1$
		nodes = new Hashtable<Integer, String>();

		try {
			Enumeration<?> portList = CommPortIdentifier.getPortIdentifiers();

			while (portList.hasMoreElements()) {
				CommPortIdentifier portId = (CommPortIdentifier) portList.nextElement();

				if (portId.getPortType() == CommPortIdentifier.PORT_SERIAL) {
					if (portId.getName().equals(serialPortName)) {
						port = (SerialPort) portId.open("serial xbee", 2000); //$NON-NLS-1$
						input = port.getInputStream();
						output = port.getOutputStream();
						if (baudRate > 0) {
							parent.printMessage("baudrate: " + baudRate);
							port.setSerialPortParams(baudRate, databits, stopbits, parity);
						} else {
							port.setSerialPortParams(rate, databits, stopbits, parity);
						}
						port.setFlowControlMode(SerialPort.FLOWCONTROL_RTSCTS_IN);
						port.setFlowControlMode(SerialPort.FLOWCONTROL_RTSCTS_OUT);
						port.addEventListener(this);
						port.notifyOnDataAvailable(true);

						parent.printMessage(Messages.getString("IOModule.Started") //$NON-NLS-1$
								+ serialPortName);
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
		} else {
			parent.printMessage("Configuring the XBee module...");
			// NOTE: the following procedure is only valid for XBee 802.15.4
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

			nodeDiscoveryTask = new NodeDiscoveryTask(parent, xbee);
			scheduler = Executors.newSingleThreadScheduledExecutor();
			scheduler.schedule(nodeDiscoveryTask, 1, TimeUnit.SECONDS);
			scheduler.schedule(nodeDiscoveryTask, 4, TimeUnit.SECONDS);
			scheduler.schedule(nodeDiscoveryTask, 7, TimeUnit.SECONDS);
		}
	}

	public void dispose() {
		if (xbee != null) {
			byte[] command = new byte[] {
					'+', '+', '+'
			};
			byte[] apiModeCommand = new byte[] {
					'A', 'T', 'A', 'P', '0', ',', ' ', 'C', 'N', 13
			};
			try {
				printMessage("Reverteing the API mode setting to 0"); //$NON-NLS-1$
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

		new Thread() {
			@Override
			public void run() {
				port.removeEventListener();
				port.close();
				port = null;
			}
		}.start();
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

	public void notifyUpdate(int source, int from, int counts) {
		Object[] results = new Object[2 + counts];
		results[0] = new Integer(source);
		results[1] = new Integer(from);
		for (int i = 0; i < counts; i++) {
			results[2 + i] = new Float(inputData[source][from + i]);
		}

		OSCMessage message = new OSCMessage("/in", results);
		parent.getCommandPortServer().sendMessageToClients(message);
	}

	public void reboot() {
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
			xbee.setDIOConfiguration(moduleId, port, FLOAT_ZERO.equals(arguments[index]) ? 4 : 5);
		}
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

	public void sendSystemExclusiveMessage(Object[] arguments) {
		return;
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

	public void rxPacketEvent(int source, int rssi, int options, int[] data) {
		this.rssi[source] = rssi;
	}

	public void rxIOStatusEvent(int source, int rssi, float[] inData) {
		this.rssi[source] = rssi;
		for (int i = 0; i < inData.length; i++) {
			if (inData[i] >= 0) {
				inputData[source][i] = inData[i];
			}
		}
		notifyUpdate(source, 0, inData.length);
	}

	public void networkingIdentificationEvent(int my, int sh, int sl, int db, String ni) {
		String info = "NODE: MY=" + Integer.toHexString(my) + ", SH=" + Integer.toHexString(sh) + ", SL=" + Integer.toHexString(sl) + ", dB=" + db
				+ ", NI=\'" + ni + "\'";
		OSCMessage message = new OSCMessage("/node");
		message.addArgument(new Integer(my));
		message.addArgument(new String(ni));
		parent.getCommandPortServer().sendMessageToClients(message);
		if (!nodes.containsKey(new Integer(my))) {
			nodes.put(new Integer(my), ni);
			parent.printMessage(info);
		}
	}

	public void firmwareVersionEvent(String version) {
		parent.printMessage(version);
	}

	public void sourceAddressEvent(String sourceAddress) {
		parent.printMessage(sourceAddress);
	}

	public void panIdEvent(String panId) {
		parent.printMessage(panId);
	}

	public void apiModeEvent(String apiMode) {
		parent.printMessage(apiMode);
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

	public void unsupportedApiEvent(String apiIdentifier) {
		parent.printMessage(apiIdentifier);
	}

	public void stringMessageEvent(String errorMessage) {
		parent.printMessage(errorMessage);
	}
}
