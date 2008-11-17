package processing.funnel;

import com.illposed.osc.OSCMessage;

import processing.core.PApplet;

import processing.funnel.i2c.*;

/**
 * @author endo
 * @version 1.1
 * 
 */
public final class Arduino extends IOSystem{
	
	public static final String moduleName = "Arduino";
	/**
	 * always 0
	 */
	public static final int moduleID = 0;//

	public static final int IN = PORT_DIN;
	public static final int OUT = PORT_DOUT;
	public static final int PWM = PORT_AOUT;
	
	
	private static final int[] firmata = {
		PORT_DOUT,PORT_DOUT,PORT_DOUT,PORT_AOUT,PORT_DOUT,PORT_AOUT,PORT_AOUT,
		PORT_DOUT,PORT_DOUT,PORT_AOUT,PORT_AOUT,PORT_AOUT,PORT_DOUT,PORT_DOUT,
		PORT_AIN,PORT_AIN,PORT_AIN,PORT_AIN,PORT_AIN,PORT_AIN,PORT_AIN,PORT_AIN,
	};
	public static final Configuration FIRMATA = new Configuration(moduleID,firmata,moduleName);

	
	
	

	/**
	 * arduinoのポート番号からfunnelのポート番号への変換
	 */
	static final int[] _a = {14,15,16,17,18,19,20,21};
	static final int[] _d = {0,1,2,3,4,5,6,7,8,9,10,11,12,13};
	

	public Arduino(PApplet parent, String hostName,
			int commandPortNumber ,int samplingInterval,Configuration config){
		super(parent,hostName,commandPortNumber,samplingInterval,config);
		
		if(!initialize(moduleID,config)){
			errorMessage("Funnel configuration error!");
		}
		addModule(moduleID,config,config.getModuleName());
		
		initPorts(_a,_d);
		
		startIOSystem();
	}
	
	public Arduino(PApplet parent,Configuration config){
		
		this(parent,"localhost",CommandPort.defaultPort,
				33,config);
	}

	public Arduino(PApplet parent, int samplingInterval, Configuration config ){
		
		this(parent,"localhost",CommandPort.defaultPort,
				samplingInterval,config);
	}

	public Arduino(PApplet parent,
			int commandPortNumber, int samplingInterval,Configuration config ){
		
		this(parent,"localhost",commandPortNumber,
				samplingInterval,config);
	}
	
	
	//Arduinoショートカット
	public IOModule.Port analogPin(int nPort){
		return iomodule(moduleID).analogPin(nPort);
	}
	
	public IOModule.Port digitalPin(int nPort){
		return iomodule(moduleID).digitalPin(nPort);
	} 
	
	public IOModule iomodule(){
		return iomodule(moduleID);
	}
	
	
	public void sendSysex(int argc,byte[] argv){
		
		Object args[] = new Object[argc+1];
		args[0] = new Integer(moduleID);
		
		for(int i=0;i<argc;i++){
			args[i+1] = new Integer(argv[i]);
		}
		
		execCode("/sysex",args,false);
	}
	
	protected void waitMessage(OSCMessage message){
		super.waitMessage(message);
		
		if(message.getAddress().equals("/sysex")){
			if(((Integer)message.getArguments()[1]).intValue() == 0x76){
				
				int modid = ((Integer)message.getArguments()[0]).intValue();
				
				int slaveAddress = ((Integer)message.getArguments()[2]).intValue();
				int registerAddress = ((Integer)message.getArguments()[3]).intValue();
				
				IOModule io = iomodule(modid);
				I2CInterface i2c = io.i2cdevice(slaveAddress);
				
				int len = message.getArguments().length-4;
				byte[] data = new byte[len];
				for(int i=0;i<len;i++){
					data[i] = ((Integer)message.getArguments()[4+i]).byteValue();
				}
				i2c.receiveData(registerAddress, data);
				
			}			
			
//			System.out.println("     ----wait sysex Message");
//			System.out.print("       ");
//			for(int i=0;i<message.getArguments().length;i++){
//				int v = ((Integer)message.getArguments()[i]).intValue();
//				
//				System.out.print("0x"+Integer.toHexString(v ) + "  ");
//			
//			}
//			System.out.println();
			
		}
		
	}
}



	
