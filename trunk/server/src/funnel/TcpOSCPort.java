package funnel;

import java.io.IOException;
import java.net.InetAddress;
import java.net.Socket;

import com.illposed.osc.OSCPortOut;

/**
 * OSCPort is an abstract superclass. To send OSC messages, use
 * 
 * @see OSCPortOut. To listen for OSC messages, use
 * @see OSCPortIn.
 *      <p>
 *      Copyright (C) 2003-2006, C. Ramakrishnan / Illposed Software. All rights
 *      reserved.
 *      <p>
 *      See license.txt (or license.rtf) for license information.
 * 
 * @author Chandrasekhar Ramakrishnan
 * @version 1.0
 */
public abstract class TcpOSCPort {

	protected InetAddress address;
	protected Socket socket;
	protected int port;

	/**
	 * デフォルトのFunnelのポート
	 */
	public static int defaultFunnelOSCPort() {
		return 9000;
	}

	/**
	 * Close the socket if this hasn't already happened.
	 * 
	 * @see java.lang.Object#finalize()
	 */
	protected void finalize() throws Throwable {
		super.finalize();
		socket.close();
	}

	public void close() {
		try {
			socket.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	public boolean isAlive() {
		if (this.socket == null) {
			return false;
		}

		return this.socket.isConnected();
	}
}
