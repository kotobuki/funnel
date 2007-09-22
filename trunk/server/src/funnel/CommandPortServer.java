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
import java.util.Vector;

public class CommandPortServer extends Server {
	public CommandPortServer(FunnelServer parent, int port) {
		this.parent = parent;
		this.port = port;
		clist = new Vector();
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
						+ Messages
								.getString("CommandPortServer.ClientConnected")); //$NON-NLS-1$
			}
		} catch (IOException ioe) {
			printMessage(Messages
					.getString("CommandPortServer.ErrorInsideServer")); //$NON-NLS-1$
			ioe.printStackTrace();
			stopServer();
		}
	}
}
