package processing.funnel;

import processing.core.PApplet;

public final class XBee extends IOSystem{

	
	public static final String moduleName = "xbee";
	
	/**
	 * 0xFFFF : broadcast
	 */
	public static final int moduleID = 0xFFFF;//
	
	public static final int AIN = PORT_AIN;
	public static final int DIN = PORT_DIN;
	public static final int OUT = PORT_DOUT;

	
	//XBee 802.15.4
	private static final int[] multipoint = {
		PORT_AIN, PORT_AIN, PORT_AIN, PORT_AIN, PORT_AIN, PORT_AIN,
		PORT_DIN, PORT_DIN,
	};
	public static final Configuration MULTIPOINT = new Configuration(moduleID,multipoint,moduleName);
	
	//XBee ZB ZigBee PRO
	private static final int[] zb = {
		PORT_AIN, PORT_AIN, PORT_AIN, PORT_AIN,
		PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN,
	};
	public static final Configuration ZB = new Configuration(moduleID,zb,moduleName);
	
	/**
	 * XBeeのポート番号からfunnelのポート番号への変換
	 */
	static final int[] _a = {0,1,2,3,4,5};
	static final int[] _d = {6,7};
	
	public XBee(PApplet parent, String hostName,
			int commandPortNumber,int samplingInterval,int[] IDs,Configuration config){
		super(parent,hostName,commandPortNumber,samplingInterval,config);

		if(!initialize(moduleID,config)){
			errorMessage("Funnel configuration error!");
		}
		for(int i=0;i<IDs.length;i++){
			String name = "xbee." + i;
			addModule(IDs[i],config,name);
		}
		
		initPorts(_a,_d);
		
		startIOSystem();
	}
	
	public XBee(PApplet parent,int[] IDs){	
		this(parent,"localhost",CommandPort.defaultPort,
				33,IDs,MULTIPOINT);
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
			int commandPortNumber, int samplingInterval,int[] IDs, Configuration config ){
		
		this(parent,"localhost",commandPortNumber,
				samplingInterval,IDs,config);
	}
	


}
