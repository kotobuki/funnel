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
	
	public NotifyPort notifyPort;
	public CommandPort commandPort;
	public InetAddress host;
	
	public OSCClient(){
		
	}
	
	public void cleanOSCPort(){
		
		try {
			notifyPort.stopListening();
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
		
		notifyPort.close();
		
		
		commandPort.close();

	}
	
	public boolean openFunnel(String hostName, int commandPortNumber,int notifyPortNumber){
		
		InetAddress host;
		try {
			host = InetAddress.getByName(hostName);
			System.out.println("host adress " + host.getHostAddress());
			commandPort = new CommandPort(host,commandPortNumber);
			notifyPort = new NotifyPort(host,notifyPortNumber);
			
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
	
	public OSCMessage readFunnel(String adress,int timeout) throws IOException, TimeoutException{
		
			return commandPort.receive(adress, timeout);
	}
	

}
