package processing.funnel;

import java.net.*;
import java.io.*;


import com.illposed.osc.*;
import com.illposed.osc.utility.OSCByteArrayToJavaConverter;
import com.illposed.osc.utility.OSCPacketDispatcher;

/**
 * @author endo
 * @version 1.0
 * 
 */
public final class CommandPort extends TcpOSCPort implements Runnable{

	private OutputStream out;
	private InputStream in;
	
	//state for listening
	private boolean isListening = false;

	private OSCByteArrayToJavaConverter converter = new OSCByteArrayToJavaConverter();
	private OSCPacketDispatcher dispatcher = new OSCPacketDispatcher();
	
	private Thread thread;
	

	/**
	 * default port number 9000
	 */
	static public int defaultPort = 9000; 

	public CommandPort(InetAddress newAddress, int newPort)
		throws IOException {

		address = newAddress;
		port = newPort;
		
		socket = new Socket(address,port);
		out = socket.getOutputStream();
		in = socket.getInputStream();
		
	}


	public CommandPort(InetAddress newAddress) throws IOException {
		this(newAddress, defaultPort);
	}


	public CommandPort() throws UnknownHostException, IOException {
		this(InetAddress.getLocalHost(), defaultPort);
	}
	
	public void run() {
		System.out.println("notify thread start");
		while(isListening){
			try{
				receive();
			}catch(IOException e){ 
				isListening = false;
				
				//e.printStackTrace();
			} 
		}
		System.out.println("notify thread out");
	}
	
	
	
	/**
	 *
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
		
		while(isListening){
			isListening = false;
			thread.join(2000);
		}
	}
	

	
	/**
	 */
	public void addListener(String anAddress, OSCListener listener) {
		dispatcher.addListener(anAddress, listener);
	}
	
	public void send(OSCPacket aPacket) throws IOException {
		byte[] byteArray = aPacket.getByteArray();
		  
//		OSCMessage mes = (OSCMessage)aPacket;
//		System.out.print("mes (send) " + mes.getAddress() + "   ");
//		for(int i=0;i<mes.getArguments().length;i++){
//			System.out.print(mes.getArguments()[i] + "   " );
//		}
//		System.out.println( " " );
		
		byte[] tcpPacket = new byte[byteArray.length+4];
		//System.out.println(" byteArray.length " + byteArray.length);
		// Reference: http://opensoundcontrol.org/spec-1_0
		// The first 4 bytes should be a packet size in int32 (big-endian)
		tcpPacket[0] = (byte) ((byteArray.length >>> 24) & 0xFF);
		tcpPacket[1] = (byte) ((byteArray.length >>> 16) & 0xFF);
		tcpPacket[2] = (byte) ((byteArray.length >>> 8) & 0xFF);
		tcpPacket[3] = (byte) ((byteArray.length >>> 0) & 0xFF);
		
		System.arraycopy(byteArray, 0, tcpPacket, 4, byteArray.length);

		out.write(tcpPacket);
		out.flush();
	}
	
	//
	public synchronized void receive() throws IOException,ArrayIndexOutOfBoundsException{

		byte[] buffer = new byte[1536]; // this is a common MTU
		OSCMessage message = new OSCMessage("nil");

		int readBytes = in.read(buffer,0,1536);
		int processedSize = 0;

		while (processedSize < readBytes) {
			int packetSize = (buffer[processedSize + 0] & 0xFF << 24)
					+ (buffer[processedSize + 1] & 0xFF << 16)
					+ (buffer[processedSize + 2] & 0xFF << 8)
					+ buffer[processedSize + 3] & 0xFF;
			
			byte[] packet = new byte[packetSize];
			System.arraycopy(buffer, processedSize + 4, packet, 0,packetSize);
			message = (OSCMessage)converter.convert(packet, packetSize);
//			System.out.print("mes recv " + message.getAddress() + "   ");
//			for(int i=0;i<message.getArguments().length;i++){
//				System.out.print(message.getArguments()[i] + "   " );
//			}
//			System.out.println( " " );
			dispatcher.dispatchPacket(message);

			processedSize += packetSize + 4;
		}		
	}
	
	public void close(){
		try{
			out.close();
			//in.close();
			socket.close();

		}catch(IOException e){
			e.printStackTrace();
		}
	}
	
}
