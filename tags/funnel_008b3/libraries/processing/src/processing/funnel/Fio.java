package processing.funnel;

import java.text.NumberFormat;
import processing.core.PApplet;

/**
 * @author endo
 * @version 1.0
 * 
 */
public final class Fio extends IOSystem{
	
	public static final String moduleName = "Fio";
	
	/**
	 * 0xFFFF : broadcast
	 */
	public static final int moduleID = 0xFFFF;//
	
	public static final int IN = PORT_DIN;
	public static final int OUT = PORT_DOUT;
	public static final int PWM = PORT_AOUT;
	
	private static final int[] fio = {
		PORT_DOUT,PORT_DOUT,PORT_DOUT,PORT_AOUT,PORT_DOUT,PORT_AOUT,PORT_AOUT,
		PORT_DOUT,PORT_DOUT,PORT_AOUT,PORT_AOUT,PORT_AOUT,PORT_DOUT,PORT_DOUT,
		PORT_AIN,PORT_AIN,PORT_AIN,PORT_AIN,PORT_AIN,PORT_AIN,PORT_AIN,PORT_AIN,
	};
	public static final Configuration FIRMATA = new Configuration(moduleID,fio,moduleName);
	
	//ポートの機能(参照する名前)
	private int analogPin[];
	private int digitalPin[];
	
	/**
	 * Fio ポート番号からfunnelのポート番号への変換
	 */
	static int[] _a = {14,15,16,17,18,19,20,21};
	static int[] _d = {0,1,2,3,4,5,6,7,8,9,10,11,12,13};
//	static int[] _dout = {};


	public Fio(PApplet parent, String hostName,
			int commandPortNumber,int samplingInterval,int[] IDs,Configuration config){
		super(parent,hostName,commandPortNumber,samplingInterval,config);

		regModule(IDs,config);
		
		if(!initialize(moduleID,config)){
			errorMessage("Funnel configuration error!");
		}

		
		
		initPorts(config.portStatus);
		
		
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
		
			String name = "Fio.node" + nf.format(i);
			addModule(IDs[i],config,name);
		}
	}
	
	//ポートの機能(参照する名前)を割り当てる
	private void initPorts(int[] conf){
		
		analogPin = _a;
		digitalPin = _d;

	}

//	public FioIOModule iomodule(int id){
//		FioIOModule io = (FioIOModule)iomodules.get(new Integer(id)); 
//		return io;
//	}
//	
}
