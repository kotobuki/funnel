package funnel;

import java.io.IOException;
import java.net.Socket;
import java.net.SocketException;

import com.illposed.osc.OSCListener;
import com.illposed.osc.OSCMessage;
import com.illposed.osc.OSCPacket;
import com.illposed.osc.utility.OSCPacketDispatcher;

public class CommandPortClient extends Client implements Runnable {
	class Tokenizer implements OSCListener {
		private CommandPortClient parent;

		public Tokenizer(CommandPortClient client) {
			this.parent = client;
			client.addListener("/quit", this);
			client.addListener("/reset", this);
			client.addListener("/in", this);
			client.addListener("/in/*", this);
			// Since the addListener method is as follows,
			// it's not possible to add listener for /in/[0..3]
			// addListener(java.lang.String address, OSCListener listener)
			client.addListener("/out", this);
			client.addListener("/polling", this);
			client.addListener("/samplingInterval", this);
			client.addListener("/configure", this);
		}

		public void acceptMessage(java.util.Date time, OSCMessage message) {
			parent.handleMessage(message);
		}

		/**
		 * This is a dummy method to constrain 'never used locally' warning
		 */
		public void init() {

		}
	}

	// state for listening
	private boolean isListening;
	private OSCPacketDispatcher dispatcher = new OSCPacketDispatcher();
	private Tokenizer tokenizer;

	public final int NO_ERROR = 0;
	public final int ERROR = -1;
	public final int REBOOT_ERROR = -2;
	public final int CONFIGURATION_ERROR = -3;

	/**
	 * Create an OSCPort that listens on the specified port.
	 * 
	 * @param port
	 *            UDP port to listen on.
	 * @throws SocketException
	 */
	public CommandPortClient(Server server, Socket socket) throws IOException {
		super(server, socket);
		tokenizer = new Tokenizer(this);
		tokenizer.init();
	}

	/**
	 * Register the listener for incoming OSCPackets addressed to an Address
	 * 
	 * @param anAddress
	 *            the address to listen for
	 * @param listener
	 *            the object to invoke when a message comes in
	 */
	private void addListener(String anAddress, OSCListener listener) {
		dispatcher.addListener(anAddress, listener);
	}

	private void handleMessage(OSCMessage message) {
		// server.printMessage(message.getAddress());
		// for (int i = 0; i < message.getArguments().length; i++) {
		// server.printMessage("\t" + message.getArguments()[i]);
		// }

		if (message.getAddress().equals("/reset")) {
			try {
				server.getIOModule().reboot();
			} catch (Exception e) {
				sendSimpleReply(message.getAddress(), REBOOT_ERROR, e
						.getMessage());
			} finally {
				sendSimpleReply(message.getAddress(), NO_ERROR, null);
			}
		} else if (message.getAddress().equals("/polling")) {
			try {
				server.getIOModule().setPolling(message.getArguments());
			} catch (Exception e) {
				sendSimpleReply(message.getAddress(), ERROR, e.getMessage());
			} finally {
				sendSimpleReply(message.getAddress(), NO_ERROR, null);
			}
		} else if (message.getAddress().startsWith("/in")) {
			Object[] reply = null;
			try {
				reply = server.getIOModule().getInputs(message.getAddress(),
						message.getArguments());
			} catch (IllegalArgumentException e) {
				sendSimpleReply(message.getAddress(), ERROR, e.getMessage());
			} finally {
				sendReply(message.getAddress(), reply);
			}
		} else if (message.getAddress().equals("/out")) {
			try {
				server.getIOModule().setOutput(message.getArguments());
			} catch (Exception e) {
				sendSimpleReply(message.getAddress(), ERROR, e.getMessage());
			} finally {
				sendSimpleReply(message.getAddress(), NO_ERROR, null);
			}
		} else if (message.getAddress().equals("/samplingInterval")) {
			Integer samplingInterval = (Integer) message.getArguments()[0];
			Server.setSamplingInterval(samplingInterval.intValue());
			sendSimpleReply(message.getAddress(), NO_ERROR, null);
		} else if (message.getAddress().equals("/configure")) {
			try {
				server.getIOModule().setConfiguration(message.getArguments());
			} catch (IllegalArgumentException e) {
				sendSimpleReply(message.getAddress(), CONFIGURATION_ERROR, e
						.getMessage());
			} finally {
				sendSimpleReply(message.getAddress(), NO_ERROR, null);
			}
		} else if (message.getAddress().equals("/quit")) {
			sendSimpleReply(message.getAddress(), NO_ERROR, null);
			server.getIOModule().stopPolling();
			System.exit(0);
		}
	}

	/**
	 * Am I listening for packets?
	 */
	public boolean isListening() {
		return isListening;
	}

	/**
	 * Run the loop that listens for OSC on a socket until isListening becomes
	 * false.
	 * 
	 * @see java.lang.Runnable#run()
	 */
	public void run() {
		byte[] buffer = new byte[1536]; // this is a common MTU
		try {
			while (in.read(buffer, 0, 1536) != -1 && isListening) {
				OSCPacket oscPacket = converter.convert(buffer, in.available());
				dispatcher.dispatchPacket(oscPacket);
			}
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			server
					.printMessage(Messages
							.getString("FunnelServer.CommandPort") + getIP() + Messages.getString("Server.ClientDisconnected")); //$NON-NLS-1$
			server.getIOModule().reboot();
			close();
		}

	}

	private void sendSimpleReply(String address, int value, String message) {
		int numArguments = (message == null) ? 1 : 2;
		Object arguments[] = new Object[numArguments];
		arguments[0] = new Integer(value);
		if (message != null) {
			arguments[1] = new String(message);
		}
		OSCMessage reply = new OSCMessage(address, arguments);
		try {
			send(reply);
		} catch (Exception e) {
			server
					.printMessage("Error sending reply to the client: "
							+ address);
		}
	}

	private void sendReply(String address, Object[] arguments) {
		OSCMessage reply = new OSCMessage(address, arguments);
		try {
			send(reply);
		} catch (Exception e) {
			server
					.printMessage("Error sending reply to the client: "
							+ address);
		}
	}

	/**
	 * Start listening for incoming OSCPackets
	 */
	public void startListening() {
		isListening = true;
		Thread thread = new Thread(this);
		thread.start();
	}

	/**
	 * Stop listening for incoming OSCPackets
	 */
	public void stopListening() {
		isListening = false;
	}
}
