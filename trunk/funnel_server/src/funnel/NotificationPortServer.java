package funnel;

import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.Enumeration;
import java.util.Vector;

import com.illposed.osc.OSCBundle;
import com.illposed.osc.OSCMessage;
import com.illposed.osc.OSCPacket;

public class NotificationPortServer extends Server {
	class Notifier implements Runnable {
		public void run() {
			while (true) {
				if (clist != null && clist.isEmpty()) {
					try {
						Thread.sleep(1000);
					} catch (InterruptedException e) {
						e.printStackTrace();
					}
					continue;
				}

				if (parent.getIOModule() != null) {
					OSCBundle bundle = parent.getIOModule()
							.getAllInputsAsBundle();
					if (bundle != null) {
						sendMessageToClients(bundle);
					} else {
						// It seems that not polling now, so let's say hello to
						// find disconnected clients
						OSCMessage message = new OSCMessage("/greetings");
						sendMessageToClients(message);
						try {
							Thread.sleep(500);
						} catch (InterruptedException e) {
							e.printStackTrace();
						}
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
				Client client = (Client) elements.nextElement();
				try {
					client.send(message);
				} catch (IOException e) {
					printMessage(Messages
							.getString("FunnelServer.NotificationPort") + client.getIP() + Messages.getString("NotificationPortServer.ClientDisconnected")); //$NON-NLS-1$
					clist.remove(client);
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
				printMessage(Messages
						.getString("FunnelServer.NotificationPort") + client.getIP() + Messages.getString("NotificationPortServer.ClientConnected")); //$NON-NLS-1$
			}
		} catch (IOException ioe) {
			printMessage(Messages
					.getString("NotificationPortServer.ErrorInsideServer")); //$NON-NLS-1$
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
