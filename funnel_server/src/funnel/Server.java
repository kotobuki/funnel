package funnel;

import java.io.IOException;
import java.net.ServerSocket;
import java.util.Enumeration;
import java.util.Vector;

public class Server extends Thread {

	protected ServerSocket srvsocket;
	protected Vector<Client> clist;
	protected int port;
	protected FunnelServer parent;

	public Server() {
		super();
	}

	public Server(Runnable target) {
		super(target);
	}

	public Server(String name) {
		super(name);
	}

	public Server(ThreadGroup group, Runnable target) {
		super(group, target);
	}

	public Server(ThreadGroup group, String name) {
		super(group, name);
	}

	public Server(Runnable target, String name) {
		super(target, name);
	}

	public Server(ThreadGroup group, Runnable target, String name) {
		super(group, target, name);
	}

	public Server(ThreadGroup group, Runnable target, String name,
			long stackSize) {
		super(group, target, name, stackSize);
	}

	public GainerIO ioModule() {
		return parent.gainer;
	}

	public synchronized int getClientsCount() {
		return clist.size();
	}

	public void printMessage(String msg) {
		parent.printMessage(msg);
	}

	protected void stopServer() {
		try {
			srvsocket.close();
			printMessage("serversocket closed");
	
		} catch (IOException ioe) {
			ioe.printStackTrace();
		}
	}

	public void deleteClient(Client c) {
		printMessage(c.getIP() + " disconnected.");
		clist.remove(c);
	}

	public void dispose() {
		if (clist != null) {
			Enumeration e = clist.elements();
			while (e.hasMoreElements()) {
				CommandPortClient c = (CommandPortClient) (e.nextElement());
				c.stopListening();
			}
		}
	}

}