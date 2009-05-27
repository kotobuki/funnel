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

	private static final String buildName = "Funnel Server 009 (r627)";

	private CommandPortServer server;
	private IOModule ioModule = null;
	private TextArea loggingArea;
	private final int width = 480;
	private final int height = 270;
	private boolean hasDisposed = false;

	static public boolean embeddedMode = false;
	static public boolean initialized = false;

	public FunnelServer(String configFileName) {
		super();
		Runtime.getRuntime().addShutdownHook(new Shutdown());

		if (!embeddedMode) {
			// Close the I/O module when the window is closed
			addWindowListener(new WindowAdapter() {
				public void windowClosing(WindowEvent evt) {
					if (ioModule != null) {
						System.out.println("disposing...");
						ioModule.dispose();
						System.out.println("disposed.");
						hasDisposed = true;
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
			loggingArea = new TextArea(buildName + "\n\n", 5, 10, TextArea.SCROLLBARS_VERTICAL_ONLY); //$NON-NLS-1$
			Insets insets = this.getInsets();
			loggingArea.setBounds(insets.left, insets.top, width - (insets.left + insets.right),
					height - (insets.top + insets.bottom));
			loggingArea.setEditable(false);
			loggingArea.setFont(new Font("Monospaced", Font.PLAIN, 12)); //$NON-NLS-1$
			this.add(loggingArea);
		}

		String type = ""; //$NON-NLS-1$
		String networkPort = "9000"; //$NON-NLS-1$
		String serialPort = null;
		int baudRate = -1;

		System.out.println("current directory: " //$NON-NLS-1$
				+ new File(".").getAbsolutePath()); //$NON-NLS-1$

		try {
			Map<?, ?> settings = (Map<?, ?>) YAML.load(new FileReader(configFileName)); //$NON-NLS-1$
			Map<?, ?> serverSettings = (Map<?, ?>) settings.get("server"); //$NON-NLS-1$
			if (serverSettings.get("port") == null) { //$NON-NLS-1$
				networkPort = "9000"; //$NON-NLS-1$
			} else {
				networkPort = serverSettings.get("port").toString(); //$NON-NLS-1$
			}

			Map<?, ?> modules = (Map<?, ?>) settings.get("io"); //$NON-NLS-1$
			if (modules.get("type") == null) { //$NON-NLS-1$
				printMessage(Messages.getString("FunnelServer.TypeIsNotSpecified")); //$NON-NLS-1$
				type = "Gainer"; //$NON-NLS-1$
			} else {
				type = modules.get("type").toString(); //$NON-NLS-1$
			}

			if (modules.get("port") == null) { //$NON-NLS-1$
				printMessage(Messages.getString("FunnelServer.PortIsNotSpecified")); //$NON-NLS-1$
				if (!type.equalsIgnoreCase("Gainer")) {
					serialPort = IOModule.getSerialPortName();
					if (serialPort == null) {
						printMessage(Messages.getString("FunnelServer.NoSerialPorts")); //$NON-NLS-1$
						return;
					}
				}
			} else {
				serialPort = modules.get("port").toString(); //$NON-NLS-1$
			}

			if (modules.get("baudrate") != null) { //$NON-NLS-1$
				baudRate = Integer.valueOf(modules.get("baudrate").toString()).intValue();
			}
		} catch (FileNotFoundException e) {
			printMessage(Messages.getString("FunnelServer.NoSettingsFile")); //$NON-NLS-1$
			networkPort = "9000"; //$NON-NLS-1$
			serialPort = IOModule.getSerialPortName();
		}

		if (type.equalsIgnoreCase("gainer")) { //$NON-NLS-1$
			try {
				ioModule = new GainerIO(this, serialPort);
				ioModule.reboot();
			} catch (RuntimeException e) {
				printMessage(Messages.getString("FunnelServer.CannotOpenGainer")); //$NON-NLS-1$
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
			} catch (RuntimeException e) {
				printMessage(Messages.getString("FunnelServer.CannotOpenArduino")); //$NON-NLS-1$
				return;
			} finally {
				setTitle("Funnel Server: Arduino (Firmata v2)");
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
				setTitle("Funnel Server: FIO");
			}
		}

		server = new CommandPortServer(this, Integer.parseInt(networkPort));
		server.start();

		initialized = true;
	}

	public IOModule getIOModule() {
		return ioModule;
	}

	public CommandPortServer getCommandPortServer() {
		return server;
	}

	// Print a message on the logging console
	public void printMessage(String msg) {
		if (!embeddedMode) {
			loggingArea.append(msg + "\n"); //$NON-NLS-1$
		} else {
			System.out.println(msg); //$NON-NLS-1$
		}
	}

	// This is the start point of this application
	public static void main(String[] args) {
		String libPath = System.getProperty("java.library.path"); //$NON-NLS-1$
		System.out.println("library path: " + libPath); //$NON-NLS-1$
		String classPath = System.getProperty("java.class.path"); //$NON-NLS-1$
		System.out.println("class path: " + classPath); //$NON-NLS-1$
		System.out.println("current directory: " //$NON-NLS-1$
				+ new File(".").getAbsolutePath()); //$NON-NLS-1$

		String configFileName = "settings.txt";

		if ((args.length > 0) && (args[0] != null)) {
			String fileNameToTest = "settings." + args[0].substring(1) + ".txt";
			File file = new File(fileNameToTest);
			if (file.exists()) {
				configFileName = fileNameToTest;
			} else {
				System.out.println("Warning: " + fileNameToTest + " was not found");
				System.out.println("Usage: java -jar funnel_server.jar [OPTIONS]");
				System.out.println("Options: ");
				System.out.println("  -[gainer|arduino|xbee|fio]    I/O module type");
				System.out.println("  -embedded                     embedded mode");
				return;
			}

			for (int i = 0; i < args.length; i++) {
				String s = args[i].substring(1);
				if (s.equals("embedded")) {
					FunnelServer.embeddedMode = true;
					System.out.println("Funnel Server is running in embedded mode.");
				}
			}
		}

		new FunnelServer(configFileName);
	}

	class Shutdown extends Thread {
		public void run() {
			if (ioModule != null && !hasDisposed) {
				System.out.println("disposing...");
				ioModule.dispose();
				System.out.println("disposed.");
			}
		}
	}
}