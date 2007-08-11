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
		clist = new Vector<Client>();
	}

	public void run() {
		printMessage("CommandPortServer: starting server...");

		try {
			srvsocket = new ServerSocket(port);
			printMessage("CommandPortServer: started on port " + port);

			while (true) {
				Socket sock = srvsocket.accept();
				CommandPortClient client = new CommandPortClient(this, sock);
				clist.add(client);
				client.startListening();
				printMessage(client.getIP() + " connected to the server.");
			}
		} catch (IOException ioe) {
			printMessage("connection error inside Server. closing serversocket...");
			ioe.printStackTrace();
			stopServer();
		}
	}
}
