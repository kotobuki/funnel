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

public class XbeeIO extends IOModule implements SerialPortEventListener,
		XBeeEventListener {

	// TODO: update this portion to support XBS2
	private static final int MAX_IO_PORT = 9;

	private static final int MAX_NODES = 65535;

	private float[][] inputData = new float[MAX_NODES][MAX_IO_PORT];
	private int[] rssi = new int[MAX_NODES];

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

	private XBee xbee;

	public XbeeIO(FunnelServer server, String serialPortName, int baudRate) {
		this.parent = server;
		parent.printMessage(Messages.getString("IOModule.Starting")); //$NON-NLS-1$
		dioPortRange = new funnel.PortRange();
		dioPortRange.setRange(0, 17); 	// 8 ports (XBS1)
										// 10 ports (XBS2)
										// 18 ports (FIO 8x8)
		pwmPortRange = new funnel.PortRange();
		pwmPortRange.setRange(10, 13); // 4 ports
		nodes = new Hashtable();

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

						xbee.sendATCommand("VR");
						xbee.sendATCommand("MY");
						xbee.sendATCommand("ID");
						xbee.sendATCommand("ND");
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
		xbee = new XBee(this, output);
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
			for (int i = 0; i < 8; i++) { // was "i < MAX_IO_PORT"
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
		xbee.sendATCommand("ND");
		return;
	}

	public void setConfiguration(Object[] arguments) {
		return;
	}

	public void setOutput(Object[] arguments) {
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
				xbee.processInput(inputData);
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	public void rxPacketEvent(int source, int rssi, int options, int[] data) {
		this.rssi[source] = rssi;
	}

	public void rxIOStatusEvent(int source, int rssi, int ioEnable,
			boolean hasDigitalData, boolean hasAnalogData, int dinStatus,
			float[] analogData) {
		this.rssi[source] = rssi;
		if (hasDigitalData) {
			for (int i = 0; i < MAX_IO_PORT; i++) {
				int bitMask = 1 << i;
				if ((ioEnable & bitMask) != 0) {
					inputData[source][i] = ((dinStatus & bitMask) != 0) ? 1.0f
							: 0.0f;
				}
			}
		}
		if (hasAnalogData) {
			for (int i = 0; i < 6; i++) {
				inputData[source][i] = analogData[i];
			}
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

	public void firmwareVersionEvent(String version) {
		parent.printMessage(version);
	}

	public void sourceAddressEvent(String sourceAddress) {
		parent.printMessage(sourceAddress);
	}

	public void panIdEvent(String panId) {
		parent.printMessage(panId);
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

}
