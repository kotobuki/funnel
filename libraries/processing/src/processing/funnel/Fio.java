package processing.funnel;

import java.text.NumberFormat;


import processing.core.PApplet;

/**
 * @author endo
 * @version 1.1
 * 
 */
public final class Fio extends Firmata{
	
	public static final String moduleName = "fio";
	
	/**
	 * 0xFFFF : broadcast
	 */
	public static final int moduleID = 0xFFFF;//
	
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
	 * Fio ポート番号からfunnelのポート番号への変換
	 */
	static final int[] _a = {14,15,16,17,18,19,20,21};
	static final int[] _d = {0,1,2,3,4,5,6,7,8,9,10,11,12,13};
	

	public Fio(PApplet parent, String hostName,
			int commandPortNumber,int samplingInterval,int[] IDs,Configuration config){
		super(parent,hostName,commandPortNumber,samplingInterval,config);

		regModule(IDs,config);
		
		if(!initialize(moduleID,config)){
			errorMessage("Funnel configuration error!");
		}

		
		initPorts(_a,_d);

		startIOSystem();
	}
	
	public Fio(PApplet parent,int[] IDs,Configuration config){	
		this(parent,"localhost",CommandPort.defaultPort,
				33,IDs,config);
	}
	
	
	public Fio(PApplet parent, int samplingInterval,int[] IDs,Configuration config ){
		
		this(parent,"localhost",CommandPort.defaultPort,
				samplingInterval,IDs,config);
	}

	public Fio(PApplet parent,
			int commandPortNumber,int samplingInterval,int[] IDs ,Configuration config){
		
		this(parent,"localhost",commandPortNumber,
				samplingInterval,IDs,config);
	}

	
	private void regModule(int[] IDs,Configuration config){
		System.out.println("regModule() Fio");
		NumberFormat nf = NumberFormat.getInstance();
		nf.setMinimumIntegerDigits(2);
		
		for(int i=0;i<IDs.length;i++){
		
			String name = "Fio.ID" + nf.format(IDs[i]);
			addModule(IDs[i],config,name);
		}
	}
	


	
}
