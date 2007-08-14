package funnel;

import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.Enumeration;
import java.util.Vector;

import com.illposed.osc.OSCBundle;
import com.illposed.osc.OSCPacket;

public class NotificationPortServer extends Server {
	class Notifier implements Runnable {
		public void run() {
			while (true) {
				if (parent.getIOModule() != null) {
					OSCBundle bundle = parent.getIOModule()
							.getAllInputsAsBundle();
					if (bundle != null) {
						sendMessageToClients(bundle);
					}
				}

				try {
					Thread.sleep(Server.getSamplingInterval());
				} catch (InterruptedException e) {
					e.printStackTrace();
				}
			}
		}
	}

	Notifier notifier;
	Thread notifierThread;
	boolean isNotifierRunning = false;

	public NotificationPortServer(FunnelServer parent, int port) {
		this.parent = parent;
		this.port = port;
		clist = new Vector();
		isNotifierRunning = true;
		notifier = new Notifier();
		notifierThread = new Thread(notifier);
		notifierThread.start();
	}

	public void sendMessageToClients(OSCPacket message) {
		if (clist != null) {
			Enumeration elements = clist.elements();
			while (elements.hasMoreElements()) {
				Client c = (Client) (elements.nextElement());
				try {
					c.send(message);
				} catch (IOException e) {
					printMessage(c.getIP() + Messages.getString("NotificationPortServer.ClientDisconnected")); //$NON-NLS-1$
					clist.remove(c);
					// e.printStackTrace();
					break;
				}
			}
		}
	}

	public void run() {
		printMessage(Messages.getString("NotificationPortServer.Starting")); //$NON-NLS-1$

		try {
			srvsocket = new ServerSocket(port);
			printMessage(Messages.getString("NotificationPortServer.Started") + port); //$NON-NLS-1$

			while (true) {
				Socket sock = srvsocket.accept();
				NotificationPortClient client = new NotificationPortClient(
						this, sock);
				clist.add(client);
				printMessage(client.getIP() + Messages.getString("NotificationPortServer.ClientConnected")); //$NON-NLS-1$
			}
		} catch (IOException ioe) {
			printMessage(Messages.getString("NotificationPortServer.ErrorInsideServer")); //$NON-NLS-1$
			ioe.printStackTrace();
			stopServer();
		}
	}

	public void dispose() {
		isNotifierRunning = false;
		try {
			notifierThread.join(1000);
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
		super.dispose();
	}

}
