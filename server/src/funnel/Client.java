package funnel;

import java.io.BufferedOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.Socket;

import com.illposed.osc.OSCPacket;
import com.illposed.osc.utility.OSCByteArrayToJavaConverter;

public abstract class Client extends TcpOSCPort {

	protected Server server;
	protected Socket socket;
	protected String ip;
	protected OSCByteArrayToJavaConverter converter = new OSCByteArrayToJavaConverter();
	protected InputStream in;
	protected OutputStream out;
	protected BufferedOutputStream bufferedOut;

	public Client(Server server, Socket socket) throws IOException {
		super();
		this.server = server;
		this.socket = socket;
		this.ip = this.socket.getInetAddress().getHostAddress();
		this.in = this.socket.getInputStream();
		this.out = this.socket.getOutputStream();
		this.bufferedOut = new BufferedOutputStream(this.socket
				.getOutputStream(), 4096);
		// this.socket.setTcpNoDelay(true);
	}

	/**
	 * Close the socket and free-up resources. It's recommended that clients
	 * call this when they are done with the port.
	 */
	public void close() {
		server.deleteClient(this);

		try {
			socket.close();
		} catch (IOException e) {
			e.printStackTrace();
		}

		try {
			in.close();
		} catch (IOException e) {
			e.printStackTrace();
		}

		try {
			bufferedOut.close();
		} catch (IOException e) {
			e.printStackTrace();
		}

		try {
			out.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	/**
	 * @return the IP address
	 */
	public String getIP() {
		return ip;
	}

	/**
	 * Send an osc packet (message or bundle) to the receiver I am bound to.
	 * 
	 * @param aPacket
	 *            OSCPacket
	 */
	public void send(OSCPacket aPacket) throws IOException {
		byte[] byteArray = aPacket.getByteArray();
		byte[] packetSize = new byte[4];

		// Reference: http://opensoundcontrol.org/spec-1_0
		// The first 4 bytes should be a packet size in int32 (big-endian)
		packetSize[0] = (byte) ((byteArray.length >>> 24) & 0xFF);
		packetSize[1] = (byte) ((byteArray.length >>> 16) & 0xFF);
		packetSize[2] = (byte) ((byteArray.length >>> 8) & 0xFF);
		packetSize[3] = (byte) ((byteArray.length >>> 0) & 0xFF);
		bufferedOut.write(packetSize);
		bufferedOut.write(byteArray, 0, byteArray.length);
		bufferedOut.flush();
	}
}
