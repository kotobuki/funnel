package processing.funnel;

import processing.core.PApplet;

public final class XBee extends IOSystem{

	
	public static final String moduleName = "Xbee";
	
	/**
	 * 0xFFFF : broadcast
	 */
	public static final int moduleID = 0xFFFF;//
	
	private static final int[] xbs1 = {
    PORT_AIN, PORT_AIN, PORT_AIN, PORT_AIN, PORT_AIN, PORT_AIN,
    PORT_DIN, PORT_DIN,
	};
	public static final Configuration XBS1 = new Configuration(moduleID,xbs1,moduleName);
	//ポートの機能(参照する名前)
	//private int analogInput[] = {0,1,2,3};
	//private int analogOutput[] = {10,11,12,13};


	public XBee(PApplet parent, String hostName,
			int commandPortNumber,int samplingInterval,int[] IDs,Configuration config){
		super(parent,hostName,commandPortNumber,samplingInterval,config);

		if(!initialize(moduleID,config)){
			errorMessage("Funnel configuration error!");
		}
		for(int i=0;i<IDs.length;i++){
			String name = "Fio." + i;
			addModule(IDs[i],config,name);
		}
		startIOSystem();
	}
	
	public XBee(PApplet parent,int[] IDs){	
		this(parent,"localhost",CommandPort.defaultPort,
				33,IDs,XBS1);
	}
	
	public XBee(PApplet parent, int[] IDs, Configuration config){
		this(parent,"localhost",CommandPort.defaultPort,
				33,IDs,config);
	}
	
	public XBee(PApplet parent, int samplingInterval,int[] IDs, Configuration config ){
		
		this(parent,"localhost",CommandPort.defaultPort,
				samplingInterval,IDs,config);
	}

	public XBee(PApplet parent,
			int commandPortNumber, int notifyPortNumber,int samplingInterval,int[] IDs, Configuration config ){
		
		this(parent,"localhost",commandPortNumber,
				samplingInterval,IDs,config);
	}

}
