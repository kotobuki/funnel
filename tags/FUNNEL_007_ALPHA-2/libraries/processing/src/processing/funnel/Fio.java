package processing.funnel;

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
	
	private static final int[] fio = {
		PORT_AIN, PORT_AIN, PORT_AIN, PORT_AIN,//analog in[0 - 3]
		PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN,PORT_DIN,// PORT_DIN,
		PORT_AOUT, PORT_AOUT,PORT_AOUT, PORT_AOUT,
	};
	public static final Configuration FIO = new Configuration(moduleID,fio,moduleName);
	//ポートの機能(参照する名前)
	//private int analogInput[] = {0,1,2,3};
	//private int analogOutput[] = {10,11,12,13};


	public Fio(PApplet parent, String hostName,
			int commandPortNumber, int notifyPortNumber,int samplingInterval,int[] IDs,Configuration config){
		super(parent,hostName,commandPortNumber,notifyPortNumber,samplingInterval,config);

		if(!initialize(moduleID,config)){
			errorMessage("Funnel configuration error!");
		}
		for(int i=0;i<IDs.length;i++){
			String name = "Fio." + i;
			addModule(IDs[i],config,name);
		}
		
	}
	
	public Fio(PApplet parent,int[] IDs){	
		this(parent,"localhost",CommandPort.defaultPort,NotifyPort.defaultPort,
				33,IDs,FIO);
	}
	
	public Fio(PApplet parent, int[] IDs, Configuration config){
		this(parent,"localhost",CommandPort.defaultPort,NotifyPort.defaultPort,
				33,IDs,config);
	}
	
	public Fio(PApplet parent, int samplingInterval,int[] IDs, Configuration config ){
		
		this(parent,"localhost",CommandPort.defaultPort,NotifyPort.defaultPort,
				samplingInterval,IDs,config);
	}

	public Fio(PApplet parent,
			int commandPortNumber, int notifyPortNumber,int samplingInterval,int[] IDs, Configuration config ){
		
		this(parent,"localhost",commandPortNumber,notifyPortNumber,
				samplingInterval,IDs,config);
	}

}
