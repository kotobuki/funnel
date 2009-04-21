package processing.funnel;

import processing.core.PApplet;



/**
 * @author endo
 * @version 1.2
 * 
 */
public final class Arduino extends Firmata{
	
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
	 * Arduinoのポート番号からfunnelのポート番号への変換
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
	
	
	protected void startingServer(){
		waitingServer(moduleName);
	}
}



	
