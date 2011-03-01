package processing.funnel;

import java.io.*;
import java.net.InetAddress;
import java.net.UnknownHostException;

import com.illposed.osc.*;

/**
 * @author endo
 * @version 1.0
 * 
 */
public final class OSCClient {
	
	public CommandPort commandPort;
	public InetAddress host;
	
	public OSCClient(){
		
	}
	
	public void cleanOSCPort(){
		
		try {
			commandPort.stopListening();
			System.out.println("commandPort close");
			commandPort.close();
		} catch (InterruptedException e) {
			e.printStackTrace();
		}

	}
	
	public boolean openFunnel(String hostName, int commandPortNumber){
		
		InetAddress host;
		try {
			host = InetAddress.getByName(hostName);
			System.out.println("opened host address " + host.getHostAddress());
			commandPort = new CommandPort(host,commandPortNumber);
		
		} catch (UnknownHostException e) {
			//e.printStackTrace();
			return false;
		} catch (IOException e){
			//e.printStackTrace();
			return false;
		}
			
		return true;
	}
	
	public boolean sendFunnel(String code) throws IOException{
		
		OSCMessage msg = new OSCMessage(code);
		commandPort.send(msg);
		
		return true;
	}
	
	public boolean sendFunnel(String code,Object[] args) throws IOException{
		
		OSCMessage msg = new OSCMessage(code,args);
		
		commandPort.send(msg);
		
		return true;
	}
	
	public boolean waitFunnel(String address) throws IOException,ArrayIndexOutOfBoundsException{

		commandPort.receive();

		
		return true;
	}
	

}
