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

	private static final String buildName = "Funnel 001 (2007-10-29)";

	private CommandPortServer commandPortServer;
	private NotificationPortServer notificationPortServer;
	private IOModule ioModule = null;
	private TextArea loggingArea;
	// private boolean logEnable = false;
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
		show();
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

		// printMessage(Messages.getString("FunnelServer.License"));
		// //$NON-NLS-1$
		// printMessage("");
		// printMessage(Messages.getString("FunnelServer.Acknowledgements"));
		// //$NON-NLS-1$
		// printMessage("");

		String type = ""; //$NON-NLS-1$
		String commandPort = "9000"; //$NON-NLS-1$
		String notificationPort = "9001"; //$NON-NLS-1$
		String serialPort = null;

		try {
			Map settings = (Map) YAML.load(new FileReader("settings.yaml")); //$NON-NLS-1$
			// printMessage("Settings:"); //$NON-NLS-1$

			Map serverSettings = (Map) settings.get("server"); //$NON-NLS-1$
			if (serverSettings.get("command port") == null) { //$NON-NLS-1$
				commandPort = "9000"; //$NON-NLS-1$
			} else {
				commandPort = serverSettings.get("command port").toString(); //$NON-NLS-1$
				// printMessage("command port:" + commandPort); //$NON-NLS-1$
			}
			if (serverSettings.get("notification port") == null) { //$NON-NLS-1$
				notificationPort = "9001"; //$NON-NLS-1$
			} else {
				notificationPort = serverSettings.get("notification port") //$NON-NLS-1$
						.toString();
				// printMessage("notification port:" + notificationPort);
				// //$NON-NLS-1$
			}

			Map modules = (Map) settings.get("io"); //$NON-NLS-1$
			// printMessage("type:" + modules.get("type")); //$NON-NLS-1$
			// //$NON-NLS-2$
			// printMessage("com:" + modules.get("com")); //$NON-NLS-1$
			// //$NON-NLS-2$
			// printMessage(""); //$NON-NLS-1$

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
				serialPort = IOModule.getSerialPortName();
			} else {
				serialPort = modules.get("com").toString(); //$NON-NLS-1$
			}
		} catch (FileNotFoundException e) {
			printMessage(Messages.getString("FunnelServer.NoSettingsFile")); //$NON-NLS-1$
			commandPort = "9000"; //$NON-NLS-1$
			notificationPort = "9001"; //$NON-NLS-1$
			serialPort = IOModule.getSerialPortName();
		}

		if (serialPort == null) {
			printMessage(Messages.getString("FunnelServer.NoSerialPorts")); //$NON-NLS-1$
			return;
		}

		// Dump read setting from the settings file
		// printMessage("command server port: " + commandPort); //$NON-NLS-1$
		// printMessage("notification server port: " + notificationPort);
		// //$NON-NLS-1$
		// printMessage("serial port: " + serialPort); //$NON-NLS-1$

		if (type.equalsIgnoreCase("Gainer")) { //$NON-NLS-1$
			try {
				ioModule = new GainerIO(this, serialPort);
				ioModule.reboot();
			} catch (RuntimeException e) {
				printMessage(Messages
						.getString("FunnelServer.CannotOpenGainer")); //$NON-NLS-1$
				return;
			}
		} else if (type.equalsIgnoreCase("Arduino")) { //$NON-NLS-1$
			try {
				ioModule = new ArduinoIO(this, serialPort);
				// Arduino Diecimila will reboot automatically
			} catch (RuntimeException e) {
				printMessage(Messages
						.getString("FunnelServer.CannotOpenArduino")); //$NON-NLS-1$
				return;
			}
		} else if (type.equalsIgnoreCase("XBee")) { //$NON-NLS-1$
			try {
				ioModule = new XbeeIO(this, serialPort);
			} catch (RuntimeException e) {
				printMessage(Messages.getString("FunnelServer.CannotOpenXbee")); //$NON-NLS-1$
				return;
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
