package processing.funnel;

import java.net.*;
import java.io.InputStream;
import java.io.IOException;

import com.illposed.osc.*;
import com.illposed.osc.utility.*;

/**
 * @author endo
 * @version 1.0
 * 
 */
public final class NotifyPort extends TcpOSCPort implements Runnable {

	
	//state for listening
	private boolean isListening = false;

	private OSCByteArrayToJavaConverter converter = new OSCByteArrayToJavaConverter();
	private OSCPacketDispatcher dispatcher = new OSCPacketDispatcher();
	
	private InputStream in;
	private Thread thread;
	
	private int packetSize = 1536;
	/**
	 * default port number 9001
	 */
	static public int defaultPort = 9001;
	

	public NotifyPort(InetAddress newAddress, int newPort) throws IOException {

		address = newAddress;
		port = newPort;
		
		socket = new Socket(address,port);
		in = socket.getInputStream();
		
	}


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
		
		int readBytes = in.read(buffer,0,packetSize);

		if(readBytes>0){
			String c = new String(buffer);
			int nPackets = 0;
			for(int i=0;i<c.length();i++){
				if(c.startsWith("#bundle",i)){
					nPackets++;
				}
			}
			//System.out.println(" n " + nPackets);
			if(nPackets !=0){
				if(nPackets == 1 && packetSize == 1536){
					packetSize = readBytes;
				}
				//System.out.println(" read bytes " + readBytes);
				for(int i=0;i<nPackets;i++){
					byte[] b = new byte[packetSize];
					System.arraycopy(buffer, packetSize*i, b, 0, packetSize);
					OSCPacket oscPacket = converter.convert(b, packetSize);
					dispatcher.dispatchPacket(oscPacket);
				}
				
			}
			
		}
		
	}

	
	public synchronized void close(){
		try{
//			in.close();
			socket.close();
		}catch(IOException e){
			e.printStackTrace();
		}
	}
	

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
