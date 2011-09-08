package funnel;

/**
 * FunnelServer
 *
 * @author Funnel Development Team
 */

import java.awt.BorderLayout;
import java.awt.Container;
import java.awt.Font;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Enumeration;
import java.util.Map;

import javax.swing.JComboBox;
import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;
import javax.swing.ScrollPaneConstants;
import javax.swing.SwingUtilities;
import javax.swing.WindowConstants;

import org.jvyaml.YAML;

import gnu.io.CommPortIdentifier;

public class FunnelServer extends JFrame implements ActionListener {

	/**
	 * Generated serialVersionUID
	 */
	private static final long serialVersionUID = -2518876146630199843L;

	private static final String buildName = "Funnel Server v1.0 (r800)";

	private final String BOARD_TYPE_ARDUINO = "Arduino (StandardFirmata, 57600 baud)";
	private final String BOARD_TYPE_ARDUINO_FIO = "Arduino Fio (StandardFirmataForFio, 57600 baud)";
	private final String BOARD_TYPE_FIO = "FIO (StandardFirmataForFio, 19200 baud)";
	private final String BOARD_TYPE_GAINER = "Gainer";
	private final String BOARD_TYPE_XBEE_57600 = "XBee (57600 baud)";
	private final String BOARD_TYPE_XBEE_19200 = "XBee (19200 baud)";
	private final String BOARD_TYPE_JAPANINO = "Japanino (JapaninoPOVFirmata, 38400 baud)";

	private final int width = 480;
	private final int height = 270;

	private final String[] boardTypeStrings = {
			BOARD_TYPE_ARDUINO, BOARD_TYPE_ARDUINO_FIO, BOARD_TYPE_FIO, BOARD_TYPE_GAINER, BOARD_TYPE_XBEE_57600, BOARD_TYPE_XBEE_19200,
			BOARD_TYPE_JAPANINO
	};

	private JComboBox boards;
	private JComboBox serialPorts;

	static public boolean embeddedMode = false;
	static public boolean initialized = false;
	static public String serialPort = null;

	private CommandPortServer server;
	private IOModule ioModule = null;
	private JTextArea loggingArea;
	private boolean hasDisposed = false;
	private int baudRate = -1;
	private String boardType;

	public FunnelServer(String configFileName) {
		super();
		Runtime.getRuntime().addShutdownHook(new Shutdown());

		if (!embeddedMode) {
			// Close the I/O module when the window is closed
			addWindowListener(new WindowAdapter() {
				@Override
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

			Container contentPane = getContentPane();
			contentPane.setLayout(new BorderLayout());

			setTitle("Funnel Server"); //$NON-NLS-1$
			setSize(width, height);
			setResizable(false);

			loggingArea = new JTextArea(16, 40);
			loggingArea.setEditable(false);
			loggingArea.setFont(new Font("Monospaced", Font.PLAIN, 12)); //$NON-NLS-1$
			contentPane.add(new JScrollPane(loggingArea, ScrollPaneConstants.VERTICAL_SCROLLBAR_ALWAYS,
					ScrollPaneConstants.HORIZONTAL_SCROLLBAR_AS_NEEDED), BorderLayout.CENTER);

			loggingArea.append(buildName + "\n\n");

			JPanel settingsMenuPane = new JPanel(new BorderLayout(4, 0));

			boards = new JComboBox();
			for (int i = 0; i < boardTypeStrings.length; i++) {
				boards.addItem(boardTypeStrings[i]);
			}
			boards.addActionListener(this);

			serialPorts = new JComboBox();
			try {
				Enumeration<?> portList = CommPortIdentifier.getPortIdentifiers();
				while (portList.hasMoreElements()) {
					CommPortIdentifier portId = (CommPortIdentifier) portList.nextElement();

					if (portId.getPortType() == CommPortIdentifier.PORT_SERIAL) {
						String name = portId.getName();
						if (!name.startsWith("/dev/tty.")) {
							serialPorts.addItem(name);
						}
					}
				}
			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			serialPorts.addActionListener(this);

			settingsMenuPane.add(boards, BorderLayout.WEST);
			settingsMenuPane.add(serialPorts, BorderLayout.CENTER);
			contentPane.add(settingsMenuPane, BorderLayout.AFTER_LAST_LINE);

			setDefaultCloseOperation(WindowConstants.DISPOSE_ON_CLOSE);
			setVisible(true);
		}

		String type = ""; //$NON-NLS-1$
		String networkPort = "9000"; //$NON-NLS-1$

		try {
			Map<?, ?> settings = (Map<?, ?>) YAML.load(new FileReader(configFileName));
			if (settings != null) {
				Map<?, ?> serverSettings = (Map<?, ?>) settings.get("server"); //$NON-NLS-1$
				if (serverSettings != null) {
					if (serverSettings.get("port") == null) { //$NON-NLS-1$
						networkPort = "9000"; //$NON-NLS-1$
					} else {
						networkPort = serverSettings.get("port").toString(); //$NON-NLS-1$
					}
				}

				Map<?, ?> modules = (Map<?, ?>) settings.get("io"); //$NON-NLS-1$
				if (modules != null) {
					if (modules.get("type") == null) { //$NON-NLS-1$
						printMessage(Messages.getString("FunnelServer.TypeIsNotSpecified")); //$NON-NLS-1$
						type = "Gainer"; //$NON-NLS-1$
					} else {
						type = modules.get("type").toString(); //$NON-NLS-1$
					}
				}
				if (serialPort == null) {
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
				}

				if (modules.get("baudrate") != null) { //$NON-NLS-1$
					baudRate = Integer.valueOf(modules.get("baudrate").toString()).intValue();
				}
			}
		} catch (FileNotFoundException e) {
			printMessage(Messages.getString("FunnelServer.NoSettingsFile")); //$NON-NLS-1$
		}

		server = new CommandPortServer(this, Integer.parseInt(networkPort));
		server.start();

		if (!FunnelServer.embeddedMode) {
			serialPorts.setSelectedItem(serialPort);
			if (type.equalsIgnoreCase("gainer") || type.equals(BOARD_TYPE_GAINER)) { //$NON-NLS-1$
				boards.setSelectedItem(BOARD_TYPE_GAINER);
			} else if (type.equalsIgnoreCase("arduino") || type.equals(BOARD_TYPE_ARDUINO)) { //$NON-NLS-1$
				boards.setSelectedItem(BOARD_TYPE_ARDUINO);
			} else if (type.equalsIgnoreCase("japanino") || type.equals(BOARD_TYPE_JAPANINO)) { //$NON-NLS-1$
				boards.setSelectedItem(BOARD_TYPE_JAPANINO);
			} else if (type.equalsIgnoreCase("xbee") || type.equals(BOARD_TYPE_XBEE_19200) || type.equals(BOARD_TYPE_XBEE_57600)) { //$NON-NLS-1$
				if (baudRate == 19200) {
					boards.setSelectedItem(BOARD_TYPE_XBEE_19200);
				} else if (baudRate == 57600) {
					boards.setSelectedItem(BOARD_TYPE_XBEE_57600);
				} else {
					boards.setSelectedItem(BOARD_TYPE_XBEE_19200);
				}
			} else if (type.equalsIgnoreCase("fio") || type.equals(BOARD_TYPE_FIO) || type.equals(BOARD_TYPE_ARDUINO_FIO)) { //$NON-NLS-1$
				if (baudRate == 19200) {
					boards.setSelectedItem(BOARD_TYPE_FIO);
				} else if (baudRate == 57600) {
					boards.setSelectedItem(BOARD_TYPE_ARDUINO_FIO);
				} else {
					boards.setSelectedItem(BOARD_TYPE_ARDUINO_FIO);
				}
			} else {
				boards.setSelectedIndex(-1);
			}
		} else {
			if (type.equalsIgnoreCase("gainer") || type.equals(BOARD_TYPE_GAINER)) { //$NON-NLS-1$
				connect(BOARD_TYPE_GAINER);
			} else if (type.equalsIgnoreCase("arduino") || type.equals(BOARD_TYPE_ARDUINO)) { //$NON-NLS-1$
				connect(BOARD_TYPE_ARDUINO);
			} else if (type.equalsIgnoreCase("xbee") || type.equals(BOARD_TYPE_XBEE_19200) || type.equals(BOARD_TYPE_XBEE_57600)) { //$NON-NLS-1$
				if (baudRate == 19200) {
					connect(BOARD_TYPE_XBEE_19200);
				} else if (baudRate == 57600) {
					connect(BOARD_TYPE_XBEE_57600);
				} else {
					connect(BOARD_TYPE_XBEE_19200, baudRate);
				}
			} else if (type.equalsIgnoreCase("fio") || type.equals(BOARD_TYPE_FIO) || type.equals(BOARD_TYPE_ARDUINO_FIO)) { //$NON-NLS-1$
				if (baudRate == 19200) {
					connect(BOARD_TYPE_FIO);
				} else if (baudRate == 57600) {
					connect(BOARD_TYPE_ARDUINO_FIO);
				} else {
					connect(BOARD_TYPE_ARDUINO_FIO, baudRate);
				}
			}
		}

		initialized = true;
	}

	public IOModule getIOModule() {
		return ioModule;
	}

	public CommandPortServer getCommandPortServer() {
		return server;
	}

	// Print a message on the logging console
	public void printMessage(final String msg) {
		if (!embeddedMode) {
			SwingUtilities.invokeLater(new Runnable() {
				public void run() {
					loggingArea.append(msg + "\n"); //$NON-NLS-1$
					loggingArea.setCaretPosition(loggingArea.getDocument().getLength());
				}
			});
		} else {
			System.out.println(msg);
		}
	}

	// This is the start point of this application
	public static void main(String[] args) {
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

	public void actionPerformed(ActionEvent event) {
		if (event.getSource() == serialPorts) {
			if (ioModule != null) {
				baudRate = ioModule.getBaudRate();
				ioModule.dispose();
				ioModule = null;
			}
			connect(boardType, baudRate);
			saveSettings();
		} else if (event.getSource() == boards) {
			boardType = (String) boards.getSelectedItem();
			if (ioModule != null) {
				baudRate = ioModule.getBaudRate();
				ioModule.dispose();
				ioModule = null;
			}
			if (serialPort != null) {
				connect(boardType, baudRate);
				saveSettings();
			}
		}
	}

	private void connect(String requestedBoardType) {
		connect(requestedBoardType, -1);
	}

	private void connect(String requestedBoardType, int requestedBaudRate) {
		if (requestedBoardType == null) {
			return;
		}

		if (serialPorts != null) {
			if (serialPorts.getSelectedIndex() < 0) {
				return;
			}

			serialPort = (String) serialPorts.getSelectedItem();
		}

		if (requestedBoardType.equals(BOARD_TYPE_GAINER)) {
			try {
				ioModule = new GainerIO(this, serialPort);
				ioModule.reboot();
			} catch (RuntimeException e) {
				printMessage(Messages.getString("FunnelServer.CannotOpenGainer")); //$NON-NLS-1$
				return;
			}
		} else if (requestedBoardType.equals(BOARD_TYPE_ARDUINO)) {
			try {
				if (requestedBaudRate < 0) {
					baudRate = 57600;
				}
				ioModule = new ArduinoIO(this, serialPort, baudRate);
			} catch (RuntimeException e) {
				printMessage(Messages.getString("FunnelServer.CannotOpenArduino")); //$NON-NLS-1$
				return;
			}
		} else if (requestedBoardType.equals(BOARD_TYPE_JAPANINO)) {
			try {
				baudRate = 38400;
				ioModule = new ArduinoIO(this, serialPort, baudRate);
			} catch (RuntimeException e) {
				printMessage(Messages.getString("FunnelServer.CannotOpenArduino")); //$NON-NLS-1$
				return;
			}
		} else if (requestedBoardType.equals(BOARD_TYPE_XBEE_19200) || requestedBoardType.equals(BOARD_TYPE_XBEE_57600)) {
			try {
				if (requestedBaudRate < 0) {
					if (requestedBoardType.equals(BOARD_TYPE_XBEE_19200)) {
						baudRate = 19200;
					} else if (requestedBoardType.equals(BOARD_TYPE_XBEE_57600)) {
						baudRate = 57600;
					}
				}
				ioModule = new XbeeIO(this, serialPort, baudRate);
			} catch (RuntimeException e) {
				printMessage(Messages.getString("FunnelServer.CannotOpenXBee")); //$NON-NLS-1$
				return;
			}
		} else if (requestedBoardType.equals(BOARD_TYPE_ARDUINO_FIO) || requestedBoardType.equals(BOARD_TYPE_FIO)) {
			try {
				if (requestedBaudRate < 0) {
					if (requestedBoardType.equals(BOARD_TYPE_FIO)) {
						baudRate = 19200;
					} else if (requestedBoardType.equals(BOARD_TYPE_ARDUINO_FIO)) {
						baudRate = 57600;
					}
				}
				ioModule = new FunnelIO(this, serialPort, baudRate);
			} catch (RuntimeException e) {
				printMessage(Messages.getString("FunnelServer.CannotOpenFio")); //$NON-NLS-1$
				return;
			}
		}

		if (!FunnelServer.embeddedMode) {
			setTitle("Funnel Server: " + (String) boards.getSelectedItem());
		}
	}

	private void saveSettings() {
		if (server == null) {
			return;
		}

		if (ioModule == null) {
			return;
		}

		if ((boards.getSelectedIndex() < 0) || (serialPorts.getSelectedIndex() < 0)) {
			return;
		}

		try {
			FileWriter settingsFileWriter = new FileWriter("settings.txt");
			settingsFileWriter.write("server:\n");
			settingsFileWriter.write("  port: " + server.port + "\n");
			settingsFileWriter.write("\n");
			settingsFileWriter.write("io:\n");
			settingsFileWriter.write("  type: " + (String) boards.getSelectedItem() + "\n");
			settingsFileWriter.write("  port: " + (String) serialPorts.getSelectedItem() + "\n");
			settingsFileWriter.write("  baudrate: " + ioModule.getBaudRate() + "\n");
			settingsFileWriter.flush();
			settingsFileWriter.close();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	class Shutdown extends Thread {
		@Override
		public void run() {
			if (ioModule != null && !hasDisposed) {
				System.out.println("disposing...");
				server.dispose();

				// Just to be safe, wait 0.5s
				try {
					Thread.sleep(500);
				} catch (InterruptedException e) {
					e.printStackTrace();
				}

				ioModule.dispose();

				// Just to be safe, wait 0.5s
				try {
					Thread.sleep(500);
				} catch (InterruptedException e) {
					e.printStackTrace();
				}
				System.out.println("disposed.");
			}
		}
	}
}
