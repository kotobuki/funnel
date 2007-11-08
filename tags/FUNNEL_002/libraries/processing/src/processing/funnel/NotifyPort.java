package processing.funnel;



import java.net.*;
import java.io.InputStream;
import java.io.IOException;

import com.illposed.osc.*;
import com.illposed.osc.utility.*;

public final class NotifyPort extends TcpOSCPort implements Runnable {

	// state for listening
	private boolean isListening = false;

	private OSCByteArrayToJavaConverter converter = new OSCByteArrayToJavaConverter();
	private OSCPacketDispatcher dispatcher = new OSCPacketDispatcher();
	
	private InputStream in;
	private Thread thread;
	
	static public int defaultPort = 9001;
	
	/**
	 */
	public NotifyPort(InetAddress newAddress, int newPort) throws IOException {

		address = newAddress;
		port = newPort;
		
		socket = new Socket(address,port);
		in = socket.getInputStream();
		
	}

	/**

	 */
	public void run() {
		while(isListening){
			try{
				readPort();
			}catch(IOException e){ 
				e.printStackTrace();
			}
		}
		System.out.println("notify thread out");
	}
	
	private synchronized void readPort() throws IOException{
		// buffers were 1500 bytes in size, but this was
		// increased to 1536, as this is a common MTU
		byte[] buffer = new byte[1536];
		
		int readBytes = in.read(buffer);
		if(readBytes>0){
			OSCPacket oscPacket = converter.convert(buffer, readBytes);
			dispatcher.dispatchPacket(oscPacket);
		}
		
	}
	/**

	 */
	public synchronized void close(){
		try{
//			in.close();
			socket.close();
		}catch(IOException e){
			e.printStackTrace();
		}
	}
	
	/**

	 */
	public void startListening() {
		isListening = true;
		thread = new Thread(this,"NotifyThread");
		thread.start();
	}
	
	/**
	 * @throws InterruptedException 
	 */
	public void stopListening() throws InterruptedException {
		
		while(isListening()){
			isListening = false;
			thread.join(1000);
		}
	}
	
	/**
	 */
	public boolean isListening() {
		return isListening;
	}
	
	/**
	 */
	public void addListener(String anAddress, OSCListener listener) {
		dispatcher.addListener(anAddress, listener);
	}
	

}
