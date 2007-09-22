package processing.funnel;

import java.net.*;

/**
 * @version 1.0
 */
public abstract class TcpOSCPort {

	
	protected InetAddress address;
	protected Socket socket;
	protected int port;

	
	/**
	 */
	protected void finalize() throws Throwable {
		super.finalize();
		
		try{
			socket.close();
		}catch(SocketException e){
			System.out.println("socket closed");
		}
	}
	
	

}
