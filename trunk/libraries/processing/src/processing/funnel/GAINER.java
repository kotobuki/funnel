package processing.funnel;

import java.util.Arrays;

import processing.core.PApplet;


public final class GAINER extends IOSystem{

	public static final String moduleName = "GAINER";
	public static final int moduleID = 0;//
	
	
	private static final int[] conf1 = {
		PORT_AIN, PORT_AIN, PORT_AIN, PORT_AIN,
		PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN,
		PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT,
		PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT,
		PORT_DOUT, PORT_DIN,  // LED, BUTTON
	};
	public static final Configuration CONFIGURATION_1 = new Configuration(moduleID,conf1,moduleName);

	
	private static final int[] conf2 = {
    PORT_AIN, PORT_AIN, PORT_AIN, PORT_AIN,
    PORT_AIN, PORT_AIN, PORT_AIN, PORT_AIN,
    PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT,
    PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT,
    PORT_DOUT, PORT_DIN,  // LED, BUTTON
	};
	public static final Configuration CONFIGURATION_2 = new Configuration(moduleID,conf2,moduleName);
	
	
	public static final int[] conf3 = {
		PORT_AIN, PORT_AIN, PORT_AIN, PORT_AIN,
		PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN,
    PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT,
    PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT,
    PORT_DOUT, PORT_DIN,  // LED, BUTTON		
	};
	public static final Configuration CONFIGURATION_3 = new Configuration(moduleID,conf3,moduleName);
	
		
	public static final int[] conf4 = {
		 PORT_AIN, PORT_AIN, PORT_AIN, PORT_AIN,
		 PORT_AIN, PORT_AIN, PORT_AIN, PORT_AIN,
		 PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT,
		 PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT,
		 PORT_DOUT, PORT_DIN,  // LED, BUTTON	
	};
	public static final Configuration CONFIGURATION_4 = new Configuration(moduleID,conf4,moduleName);
	
	
	public static final int[] conf5 = {
		 PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN,
		 PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN,
		 PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN,
		 PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN,	
	};
	public static final Configuration CONFIGURATION_5 = new Configuration(moduleID,conf5,moduleName);
	

	public static final int[] conf6 = {
		 PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT,
		 PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT,
		 PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT,
		 PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT,		
	};
	public static final Configuration CONFIGURATION_6 = new Configuration(moduleID,conf6,moduleName);
	
	
	public static final int[] conf7 = {
		 PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT,
		 PORT_AOUT, PORT_AOUT, PORT_AOUT, // [0..7, 0]
		  PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT,
		 PORT_AOUT, PORT_AOUT, PORT_AOUT, // [0..7, 1]
		  PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT,
		 PORT_AOUT, PORT_AOUT, PORT_AOUT, // [0..7, 2]
		  PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT,
		 PORT_AOUT, PORT_AOUT, PORT_AOUT, // [0..7, 3]
		  PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT,
		 PORT_AOUT, PORT_AOUT, PORT_AOUT, // [0..7, 4]
		  PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT,
		 PORT_AOUT, PORT_AOUT, PORT_AOUT, // [0..7, 5]
		  PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT,
		 PORT_AOUT, PORT_AOUT, PORT_AOUT, // [0..7, 6]
		  PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT,
		 PORT_AOUT, PORT_AOUT, PORT_AOUT, // [0..7, 7]
		
	};
	public static final Configuration CONFIGURATION_7 = new Configuration(moduleID,conf7,moduleName);
	
	
	public static final int[] conf8 = {
		 PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN,
		 PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN,
		 PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT,
		 PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT,	
	};
	public static final Configuration CONFIGURATION_8 = new Configuration(moduleID,conf8,moduleName);
	
	
	//ポートの名前
	public static int LED;
	public static int button;
	public static int analogInput[];
	public static int digitalInput[];
	public static int analogOutput[];
	public static int digitalOutput[];
	

	public GAINER(PApplet parent, String hostName,
			int commandPortNumber, int notifyPortNumber,int samplingInterval,Configuration config){
		super(parent,hostName,commandPortNumber,notifyPortNumber,samplingInterval,config);
		
		initPorts(config.portStatus);
	}
	
	public GAINER(PApplet parent,Configuration config){
		
		this(parent,"localhost",CommandPort.defaultPort,NotifyPort.defaultPort,
				33,config);
	}

	public GAINER(PApplet parent, int samplingInterval, Configuration config ){
		
		this(parent,"localhost",CommandPort.defaultPort,NotifyPort.defaultPort,
				samplingInterval,config);
	}

	public GAINER(PApplet parent,
			int commandPortNumber, int notifyPortNumber,int samplingInterval,Configuration config ){
		
		this(parent,"localhost",commandPortNumber,notifyPortNumber,
				samplingInterval,config);
	}
	
	
	//出力ポート番号などを決める
	public void initPorts(int[] conf){
		if(Arrays.equals(conf,conf1)){

			int[] ain = {0,1,2,3};
			int[] din = {4,5,6,7};
			int[] aout = {8,9,10,11};
			int[] dout = {12,13,14,15};
			
			analogInput = ain;
			digitalInput = din;
			analogOutput = aout;
			digitalOutput = dout;
			
			LED = 16;
			button = 17;
			
		}else if(Arrays.equals(conf,conf2)){

			int[] ain = {0,1,2,3,4,5,6,7};
			int[] din = {};
			int[] aout = {8,9,10,11};
			int[] dout = {12,13,14,15};
			
			analogInput = ain;
			digitalInput = din;
			analogOutput = aout;
			digitalOutput = dout;
			
			LED = 16;
			button = 17;
		}else if(Arrays.equals(conf,conf3)){
			
			int[] ain = {0,1,2,3};
			int[] din = {4,5,6,7};
			int[] aout = {8,9,10,11,12,13,14,15};
			int[] dout = {};
			
			analogInput = ain;
			digitalInput = din;
			analogOutput = aout;
			digitalOutput = dout;
			
			LED = 16;
			button = 17;	
		}else if(Arrays.equals(conf,conf4)){
			
			int[] ain = {0,1,2,3,4,5,6,7};
			int[] din = {};
			int[] aout = {8,9,10,11,12,13,14,15};
			int[] dout = {};
			
			analogInput = ain;
			digitalInput = din;
			analogOutput = aout;
			digitalOutput = dout;
			
			LED = 16;
			button = 17;			
		}else if(Arrays.equals(conf,conf5)){
			
			int[] ain = {};
			int[] din = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15};
			int[] aout = {};
			int[] dout = {};
			
			analogInput = ain;
			digitalInput = din;
			analogOutput = aout;
			digitalOutput = dout;
	
		}else if(Arrays.equals(conf,conf6)){

			int[] ain = {};
			int[] din = {};
			int[] aout = {};
			int[] dout = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15};
			
			analogInput = ain;
			digitalInput = din;
			analogOutput = aout;
			digitalOutput = dout;

			
		}else if(Arrays.equals(conf,conf7)){

			int[] ain = {};
			int[] din = {};
			int[] aout = new int[64];
			for(int i=0;i<64;i++){
				aout[i] = i;
			}
			int[] dout = {};
			
			analogInput = ain;
			digitalInput = din;
			analogOutput = aout;
			digitalOutput = dout;

			
		}else if(Arrays.equals(conf,conf8)){
			
			int[] ain = {};
			int[] din = {0,1,2,3,4,5,6,7};
			int[] aout = {};
			int[] dout = {8,9,10,11,12,13,14,15};
			
			analogInput = ain;
			digitalInput = din;
			analogOutput = aout;
			digitalOutput = dout;

		}

	}



	//Gainerショートカット
	public IOModule.Port analogOutput(int nPort){
		return iomodule(0).port(GAINER.analogOutput[nPort]);
	}
	
	public IOModule.Port analogInput(int nPort){
		return iomodule(0).port(GAINER.analogInput[nPort]);
	}
	
	public IOModule.Port digitalOutput(int nPort){
		return iomodule(0).port(GAINER.digitalOutput[nPort]);
	}
	
	public IOModule.Port digitalInput(int nPort){
		return iomodule(0).port(GAINER.digitalInput[nPort]);
	}
}
