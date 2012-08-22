package processing.funnel;


import com.illposed.osc.OSCMessage;

import processing.core.PApplet;
import processing.funnel.i2c.I2CDevice;
import processing.funnel.i2c.I2CInterface;

/**
 * @author endo
 * @version 1.1
 * 
 */

public abstract class Firmata extends IOSystem{

	public static final int SERVO = 4;
	
	public Firmata(PApplet parent, String hostName, String serverPortName, 
			int commandPortNumber, int samplingInterval, Configuration config) {
		super(parent, hostName,serverPortName, commandPortNumber, samplingInterval, config);
	}

	//
	public void sendSysex(int moduleID,int argc,byte[] argv){
		
		Object args[] = new Object[argc+1];
		args[0] = new Integer(moduleID);

		for(int i=0;i<argc;i++){
			args[i+1] = new Integer(argv[i]);

		}
		
		execCode("/sysex/request",args,false);
	}
	
	//addI2CDevice()‚â‚ç‚ê‚Ä‚©‚ç‚Å‚È‚¢‚Æ
	protected void waitMessage(OSCMessage message){
		super.waitMessage(message);

		if(message.getAddress().equals("/sysex/reply") && initialized){
			
//			System.out.println("     ----wait sysex Message");
//			System.out.print("       ");
//			for(int i=0;i<message.getArguments().length;i++){
//				//int v = ((Integer)message.getArguments()[i]).intValue();
//				try{
//					int v = new Integer(message.getArguments()[i].toString()).intValue();
//					System.out.print("0x"+Integer.toHexString(v ) + "  ");
//				}catch(NumberFormatException e){
//					System.out.println(message.getArguments()[i].toString());
//				}
//			}
//			System.out.println();
			
			if(((Integer)message.getArguments()[1]).intValue() == I2CDevice.COM_I2C_REPLY){

				int modid = ((Integer)message.getArguments()[0]).intValue();
				
				int slaveAddress = ((Integer)message.getArguments()[2]).intValue();
				int registerAddress = ((Integer)message.getArguments()[3]).intValue();
				
				IOModule io = iomodule(modid);
				if(io.hasI2CDevice()){
					I2CInterface i2c = io.i2cdevice(slaveAddress);
					
					int len = message.getArguments().length-4;
	
					byte[] data = new byte[len];

					for(int i=0;i<len;i++){
						try{
							data[i] |= new Integer(message.getArguments()[4+i].toString()).byteValue();
						}catch(NumberFormatException e){
							System.out.println("sysex Message error");
						}
						
					}
					System.out.println();
					i2c.receiveData(registerAddress, data);
				}
				
			}			
			

			
		}
		
	}	
}
