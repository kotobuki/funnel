package funnel;

import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.Enumeration;
import java.util.Vector;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.TimeUnit;

import com.illposed.osc.OSCMessage;

public class NotificationPortServer extends Server {
	class Notifier implements Runnable {
		public void run() {
			while (true) {
				try {
					OSCMessage message = (OSCMessage) queue.poll(1000L,
							TimeUnit.MILLISECONDS);
					if (message != null) {
						sendMessageToClients(message);
					}
				} catch (InterruptedException e) {
					e.printStackTrace();
				}
			}
		}
	}

	Notifier notifier;
	Thread notifierThread;
	LinkedBlockingQueue<OSCMessage> queue;
	boolean isNotifierRunning = false;

	public NotificationPortServer(FunnelServer parent, int port,
			LinkedBlockingQueue<OSCMessage> queue) {
		this.parent = parent;
		this.port = port;
		this.queue = queue;
		clist = new Vector<Client>();
		isNotifierRunning = true;
		notifier = new Notifier();
		notifierThread = new Thread(notifier);
		notifierThread.start();
	}

	public void sendMessageToClients(OSCMessage message) {
		if (clist != null) {
			Enumeration elements = clist.elements();
			while (elements.hasMoreElements()) {
				Client c = (Client) (elements.nextElement());
				try {
					c.send(message);
				} catch (IOException e) {
					printMessage(c.getIP() + " disconnected.");
					clist.remove(c);
					e.printStackTrace();
					break;
				}
			}
		}
	}

	public void run() {
		printMessage("NotificationPortServer: starting server...");

		try {
			srvsocket = new ServerSocket(port);
			printMessage("NotificationPortServer: started on port " + port);

			while (true) {
				Socket sock = srvsocket.accept();
				NotificationPortClient client = new NotificationPortClient(
						this, sock);
				clist.add(client);
				printMessage(client.getIP() + " connected to the server.");
			}
		} catch (IOException ioe) {
			printMessage("connection error inside Server. closing serversocket...");
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
