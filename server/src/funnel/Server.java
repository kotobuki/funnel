package funnel;

import java.io.IOException;
import java.net.ServerSocket;

public abstract class Server extends Thread {
	protected int samplingInterval = 100;

	protected ServerSocket srvsocket;
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

	public Server(ThreadGroup group, Runnable target, String name, long stackSize) {
		super(group, target, name, stackSize);
	}

	public IOModule getIOModule() {
		return parent.getIOModule();
	}

	// public synchronized int getClientsCount() {
	// return clist.size();
	// }

	public void printMessage(String msg) {
		parent.printMessage(msg);
	}

	protected void stopServer() {
		try {
			srvsocket.close();
			printMessage(Messages.getString("Server.SocketClosed")); //$NON-NLS-1$

		} catch (IOException ioe) {
			ioe.printStackTrace();
		}
	}

	abstract public void deleteClient(Client c);

	abstract public void dispose();

	public int getSamplingInterval() {
		return samplingInterval;
	}

	public void setSamplingInterval(int samplingInterval) {
		this.samplingInterval = samplingInterval;
	}

}