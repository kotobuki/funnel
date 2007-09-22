package processing.funnel;


import java.net.*;
import java.io.*;


import com.illposed.osc.*;
import com.illposed.osc.utility.OSCByteArrayToJavaConverter;


public final class CommandPort extends TcpOSCPort {

	private OutputStream out;
	private InputStream in;
	
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

	/**
	 */
	public CommandPort() throws UnknownHostException, IOException {
		this(InetAddress.getLocalHost(), defaultPort);
	}
	
	/**
	 */
	public void send(OSCPacket aPacket) throws IOException {
	
		byte[] byteArray = aPacket.getByteArray();
		//System.out.println(new String(byteArray));//debug‚ÅŽg‚¤‚©‚à
		
	/*
		DatagramPacket packet =
			new DatagramPacket(byteArray, byteArray.length, address, port);
		socket.send(packet);
	*/

		out.write(byteArray,0,byteArray.length);
		out.flush();
	}
	
	public OSCMessage receive(String adress,int timeout) throws IOException,TimeoutException{
		
		byte[] buffer = new byte[1536];

		OSCMessage message = new OSCMessage("nil");
		long start = System.currentTimeMillis();
		
		do{
			long now = System.currentTimeMillis();
			long rest = timeout - (now-start);
			if(rest <= 0){
				System.out.println("timeout return_  " +  Thread.currentThread().getName() );
				throw new TimeoutException("TimeoutException!! " + (now - start));
			}
			OSCByteArrayToJavaConverter converter = new OSCByteArrayToJavaConverter();
			
			int readBytes = in.read(buffer,0,1536);
			if(readBytes > 0){
				//System.out.println("waiting " + adress);
				message = (OSCMessage)converter.convert(buffer, readBytes);
			}
			
		}while(!message.getAddress().equals(adress));
			
		return message;
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
