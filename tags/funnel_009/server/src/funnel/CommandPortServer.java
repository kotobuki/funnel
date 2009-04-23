package funnel;

/**
 * Server class
 *
 * @author PDP Project
 * @version 1.0
 */

import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.Enumeration;
import java.util.Vector;

import com.illposed.osc.OSCPacket;

public class CommandPortServer extends Server {
	private Vector<CommandPortClient> clist;

	public CommandPortServer(FunnelServer parent, int port) {
		this.parent = parent;
		this.port = port;
		clist = new Vector<CommandPortClient>();
	}

	public void run() {
		printMessage(Messages.getString("CommandPortServer.Starting")); //$NON-NLS-1$

		try {
			srvsocket = new ServerSocket(port);
			printMessage(Messages.getString("CommandPortServer.Started") + port); //$NON-NLS-1$

			while (true) {
				Socket sock = srvsocket.accept();
				CommandPortClient client = new CommandPortClient(this, sock);
				clist.add(client);
				client.startListening();
				printMessage(Messages.getString("FunnelServer.CommandPort") + client.getIP()
						+ Messages.getString("CommandPortServer.ClientConnected")); //$NON-NLS-1$
			}
		} catch (IOException ioe) {
			printMessage(Messages.getString("CommandPortServer.ErrorInsideServer")); //$NON-NLS-1$
			ioe.printStackTrace();
			stopServer();
		}
	}

	public void dispose() {
		if (clist != null) {
			Enumeration<CommandPortClient> clients = clist.elements();
			while (clients.hasMoreElements()) {
				CommandPortClient client = clients.nextElement();
				client.stopListening();
			}
		}
	}

	public void deleteClient(Client client) {
		clist.remove(client);
		if (clist.isEmpty()) {
			getIOModule().stopPolling();
		}
	}

	public void sendMessageToClients(OSCPacket message) {
		if (clist != null) {
			Enumeration<CommandPortClient> clients = clist.elements();
			while (clients.hasMoreElements()) {
				Client client = clients.nextElement();
				try {
					client.send(message);
				} catch (IOException e) {
					// TODO Remove the client!?
				}
			}
		}
	}

}
