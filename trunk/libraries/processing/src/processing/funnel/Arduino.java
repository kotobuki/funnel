package processing.funnel;

import processing.core.PApplet;

/**
 * @author endo
 * @version 1.0
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

	
	//ポートの機能(参照する名前)
	private int analogPin[];
	private int digitalPin[];
	

	/**
	 * arduinoのポート番号からfunnelのポート番号への変換
	 */
	static int[] _a = {14,15,16,17,18,19,20,21};
	static int[] _d = {0,1,2,3,4,5,6,7,8,9,10,11,12,13};
	

	public Arduino(PApplet parent, String hostName,
			int commandPortNumber ,int samplingInterval,Configuration config){
		super(parent,hostName,commandPortNumber,samplingInterval,config);
		
		if(!initialize(moduleID,config)){
			errorMessage("Funnel configuration error!");
		}
		addModule(moduleID,config,config.getModuleName());
		
		initPorts(config.portStatus);
		
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
			int commandPortNumber, int notifyPortNumber,int samplingInterval,Configuration config ){
		
		this(parent,"localhost",commandPortNumber,
				samplingInterval,config);
	}
	
	
//ポートの機能(参照する名前)を割り当てる
	private void initPorts(int[] conf){
		
		analogPin = _a;
		digitalPin = _d;

	}
	
 
	//Arduinoショートカット
	public IOModule.Port analogPin(int nPort){
		return iomodule(0).port(analogPin[nPort]);
	}
	
	public IOModule.Port digitalPin(int nPort){
		return iomodule(0).port(digitalPin[nPort]);
	} 
}



	
