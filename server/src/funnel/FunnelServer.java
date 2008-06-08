package funnel;

/**
 * FunnelServer
 *
 * @author Funnel Development Team
 */

import java.awt.Font;
import java.awt.Frame;
import java.awt.Insets;
import java.awt.TextArea;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.util.Map;

import org.jvyaml.YAML;

public class FunnelServer extends Frame {

	/**
	 * Generated serialVersionUID
	 */
	private static final long serialVersionUID = -2518876146630199843L;

	private static final String buildName = "Funnel 008 (2008-06-08) [EXPERIMENTAL]";

	private CommandPortServer commandPortServer;
	private NotificationPortServer notificationPortServer;
	private IOModule ioModule = null;
	private TextArea loggingArea;
	private final int width = 480;
	private final int height = 270;

	public FunnelServer() {
		super();

		// Close the I/O module when the window is closed
		addWindowListener(new WindowAdapter() {
			public void windowClosing(WindowEvent evt) {
				if (ioModule != null) {
					ioModule.stopPolling();
				}
				System.exit(0);
			}
		});

		// Create the GUI elements
		setTitle("Funnel Server"); //$NON-NLS-1$
		setSize(width, height);
		setVisible(true);
		setLayout(null);
		setResizable(false);
		loggingArea = new TextArea(
				buildName + "\n\n", 5, 10, TextArea.SCROLLBARS_VERTICAL_ONLY); //$NON-NLS-1$
		Insets insets = this.getInsets();
		loggingArea.setBounds(insets.left, insets.top, width
				- (insets.left + insets.right), height
				- (insets.top + insets.bottom));
		loggingArea.setEditable(false);
		loggingArea.setFont(new Font("Monospaced", Font.PLAIN, 12)); //$NON-NLS-1$
		this.add(loggingArea);

		String type = ""; //$NON-NLS-1$
		String commandPort = "9000"; //$NON-NLS-1$
		String notificationPort = "9001"; //$NON-NLS-1$
		String serialPort = null;
		int baudRate = -1;

		try {
			Map<?, ?> settings = (Map<?, ?>) YAML.load(new FileReader("settings.yaml")); //$NON-NLS-1$
			Map<?, ?> serverSettings = (Map<?, ?>) settings.get("server"); //$NON-NLS-1$
			if (serverSettings.get("command port") == null) { //$NON-NLS-1$
				commandPort = "9000"; //$NON-NLS-1$
			} else {
				commandPort = serverSettings.get("command port").toString(); //$NON-NLS-1$
			}
			if (serverSettings.get("notification port") == null) { //$NON-NLS-1$
				notificationPort = "9001"; //$NON-NLS-1$
			} else {
				notificationPort = serverSettings.get("notification port") //$NON-NLS-1$
						.toString();
			}

			Map<?, ?> modules = (Map<?, ?>) settings.get("io"); //$NON-NLS-1$
			if (modules.get("type") == null) { //$NON-NLS-1$
				printMessage(Messages
						.getString("FunnelServer.TypeIsNotSpecified")); //$NON-NLS-1$
				type = "Gainer"; //$NON-NLS-1$
			} else {
				type = modules.get("type").toString(); //$NON-NLS-1$
			}

			if (modules.get("com") == null) { //$NON-NLS-1$
				printMessage(Messages
						.getString("FunnelServer.PortIsNotSpecified")); //$NON-NLS-1$
				if (!type.equalsIgnoreCase("Gainer")) {
					serialPort = IOModule.getSerialPortName();
					if (serialPort == null) {
						printMessage(Messages
								.getString("FunnelServer.NoSerialPorts")); //$NON-NLS-1$
						return;
					}
				}
			} else {
				serialPort = modules.get("com").toString(); //$NON-NLS-1$
			}

			if (modules.get("baudrate") != null) { //$NON-NLS-1$
				baudRate = Integer.valueOf(modules.get("baudrate").toString())
						.intValue();
			}
		} catch (FileNotFoundException e) {
			printMessage(Messages.getString("FunnelServer.NoSettingsFile")); //$NON-NLS-1$
			commandPort = "9000"; //$NON-NLS-1$
			notificationPort = "9001"; //$NON-NLS-1$
			serialPort = IOModule.getSerialPortName();
		}

		if (type.equalsIgnoreCase("gainer")) { //$NON-NLS-1$
			try {
				ioModule = new GainerIO(this, serialPort);
				ioModule.reboot();
			} catch (RuntimeException e) {
				printMessage(Messages
						.getString("FunnelServer.CannotOpenGainer")); //$NON-NLS-1$
				return;
			} finally {
				setTitle("Funnel Server: Gainer");
			}
		} else if (type.equalsIgnoreCase("arduino")) { //$NON-NLS-1$
			try {
				if (baudRate < 0) {
					baudRate = 115200;
				}
				ioModule = new ArduinoIO(this, serialPort, baudRate);
				// Arduino Diecimila will reboot automatically
			} catch (RuntimeException e) {
				printMessage(Messages
						.getString("FunnelServer.CannotOpenArduino")); //$NON-NLS-1$
				return;
			} finally {
				setTitle("Funnel Server: Arduino");
			}
		} else if (type.equalsIgnoreCase("xbee")) { //$NON-NLS-1$
			try {
				ioModule = new XbeeIO(this, serialPort, baudRate);
			} catch (RuntimeException e) {
				printMessage(Messages.getString("FunnelServer.CannotOpenXBee")); //$NON-NLS-1$
				return;
			} finally {
				setTitle("Funnel Server: XBee");
			}
		} else if (type.equalsIgnoreCase("fio")) { //$NON-NLS-1$
			try {
				ioModule = new FunnelIO(this, serialPort, baudRate);
			} catch (RuntimeException e) {
				printMessage(Messages.getString("FunnelServer.CannotOpenFio")); //$NON-NLS-1$
				return;
			} finally {
				setTitle("Funnel Server: Funnel I/O");
			}
		}

		commandPortServer = new CommandPortServer(this, Integer
				.parseInt(commandPort));
		commandPortServer.start();

		notificationPortServer = new NotificationPortServer(this, Integer
				.parseInt(notificationPort));
		notificationPortServer.start();
	}

	public IOModule getIOModule() {
		return ioModule;
	}

	public CommandPortServer getCommandPortServer() {
		return commandPortServer;
	}

	public NotificationPortServer getNotificationPortServer() {
		return notificationPortServer;
	}

	// Print a message on the logging console
	public void printMessage(String msg) {
		loggingArea.append(msg + "\n"); //$NON-NLS-1$
	}

	// This is the start point of this application
	public static void main(String[] args) {
		String libPath = System.getProperty("java.library.path"); //$NON-NLS-1$
		System.out.println("library path: " + libPath); //$NON-NLS-1$
		String classPath = System.getProperty("java.class.path"); //$NON-NLS-1$
		System.out.println("class path: " + classPath); //$NON-NLS-1$
		System.out.println("current directory: " //$NON-NLS-1$
				+ new File(".").getAbsolutePath()); //$NON-NLS-1$

		new FunnelServer();
	}
}
