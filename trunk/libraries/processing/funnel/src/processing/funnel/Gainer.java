package processing.funnel;


import java.util.Arrays;
import java.util.Set;


import processing.core.PApplet;

/**
 * @author endo
 * @version 1.2
 * 
 */
public final class Gainer extends IOSystem{

	public static final String moduleName = "Gainer";
	/**
	 * always 0
	 */
	public static final int moduleID = 0;//
	
	
	private static final int[] conf1 = {
		PORT_AIN, PORT_AIN, PORT_AIN, PORT_AIN,
		PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN,
		PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT,
		PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT,
		PORT_DOUT, PORT_DIN,  // LED, BUTTON
	};
	public static final Configuration MODE1 = new Configuration(moduleID,conf1,moduleName);

	
	private static final int[] conf2 = {
    PORT_AIN, PORT_AIN, PORT_AIN, PORT_AIN,
    PORT_AIN, PORT_AIN, PORT_AIN, PORT_AIN,
    PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT,
    PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT,
    PORT_DOUT, PORT_DIN,  // LED, BUTTON
	};
	public static final Configuration MODE2 = new Configuration(moduleID,conf2,moduleName);
	
	
	private static final int[] conf3 = {
		PORT_AIN, PORT_AIN, PORT_AIN, PORT_AIN,
		PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN,
    PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT,
    PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT,
    PORT_DOUT, PORT_DIN,  // LED, BUTTON		
	};
	public static final Configuration MODE3 = new Configuration(moduleID,conf3,moduleName);
	
		
	private static final int[] conf4 = {
		 PORT_AIN, PORT_AIN, PORT_AIN, PORT_AIN,
		 PORT_AIN, PORT_AIN, PORT_AIN, PORT_AIN,
		 PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT,
		 PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT,
		 PORT_DOUT, PORT_DIN,  // LED, BUTTON	
	};
	public static final Configuration MODE4 = new Configuration(moduleID,conf4,moduleName);
	
	
	private static final int[] conf5 = {
		 PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN,
		 PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN,
		 PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN,
		 PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN,	
	};
	public static final Configuration MODE5 = new Configuration(moduleID,conf5,moduleName);
	

	private static final int[] conf6 = {
		 PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT,
		 PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT,
		 PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT,
		 PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT,		
	};
	public static final Configuration MODE6 = new Configuration(moduleID,conf6,moduleName);
	
	
	private static final int[] conf7 = {
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
	public static final Configuration MODE7 = new Configuration(moduleID,conf7,moduleName);
	
	
//	private static final int[] conf8 = {
//		 PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN,
//		 PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN,
//		 PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT,
//		 PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT,	
//	};
//	public static final Configuration MODE8 = new Configuration(moduleID,conf8,moduleName);
	
	
	//ポートの名前
	static public int led;
	static public int button;
	static public int analogInput[];
	static public int digitalInput[];
	static public int analogOutput[];
	static public int digitalOutput[];


	

	public Gainer(PApplet parent, String hostName,String serverPortName,
			int commandPortNumber,int samplingInterval,Configuration config){
		super(parent,hostName,serverPortName,commandPortNumber,samplingInterval,config);
		
		if(!initialize(config)){
			errorMessage("Funnel configuration error!");
		}
		
		addModule(moduleID,config,config.getModuleName());
		
		initPins(config.pinsStatus);
		
		startIOSystem();
	}
	
	public Gainer(PApplet parent,Configuration config){
		
		this(parent,"localhost",null,CommandPort.defaultPort,
				33,config);
	}
	
	public Gainer(PApplet parent,Configuration config,String serverPortName){
		
		this(parent,"localhost",serverPortName,CommandPort.defaultPort,
				33,config);
	}

	public Gainer(PApplet parent, int samplingInterval, Configuration config,String serverPortName ){
		
		this(parent,"localhost",serverPortName,CommandPort.defaultPort,
				samplingInterval,config);
	}

	public Gainer(PApplet parent,
			int commandPortNumber, int samplingInterval,Configuration config,String serverPortName ){
		
		this(parent,"localhost",serverPortName,commandPortNumber,
				samplingInterval,config);
	}
	
	
	//出力ポート番号などを決める
	private void initPins(int[] conf){
		if(Arrays.equals(conf,conf1)){

			int[] ain = {0,1,2,3};
			int[] din = {4,5,6,7};
			int[] aout = {8,9,10,11};
			int[] dout = {12,13,14,15};
			
			analogInput = ain;
			digitalInput = din;
			analogOutput = aout;
			digitalOutput = dout;
			
			led = 16;
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
			
			led = 16;
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
			
			led = 16;
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
			
			led = 16;
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

		}
//		}else if(Arrays.equals(conf,conf8)){
//			
//			int[] ain = {};
//			int[] din = {0,1,2,3,4,5,6,7};
//			int[] aout = {};
//			int[] dout = {8,9,10,11,12,13,14,15};
//			
//			analogInput = ain;
//			digitalInput = din;
//			analogOutput = aout;
//			digitalOutput = dout;
//
//		}

	}

	//Gainerは特殊  GainerIOModule(ButtonEvent)のため
	protected boolean addModule(int id,Configuration config,String name){

		System.out.println("addmodule() Gainer");
		
		Set<?> key = iomodules.entrySet();
		if(!key.contains(new Integer(id))){
			IOModule io =  new GainerIOModule(this,id,config,name);
			iomodules.put(new Integer(id),io);
			
			//dinにSetPointを自動でつける
			int[] portStatus = config.getPortStatus();
			for(int i=0;i<portStatus.length;i++){
				if(portStatus[i] == PORT_DIN){
					Filter[] filters ={ new SetPoint(0.5f,0)};
					io.pin(i).setFilters(filters);
				}
			}
			
			return true;
		}
		
		return false;
	}
	
	
	//Gainerショートカット
	public IOModule.ModulePin analogOutput(int nPort){
		return iomodule(0).pin(analogOutput[nPort]);
	}
	
	public IOModule.ModulePin analogInput(int nPort){
		return iomodule(0).pin(analogInput[nPort]);
	}
	
	public IOModule.ModulePin digitalOutput(int nPort){
		return iomodule(0).pin(digitalOutput[nPort]);
	}
	
	public IOModule.ModulePin digitalInput(int nPort){
		return iomodule(0).pin(digitalInput[nPort]);
	}
	
	public IOModule.ModulePin led(){
		return iomodule(0).pin(led);
	}
	
	public IOModule.ModulePin button(){
		return iomodule(0).pin(button);
	}
	
	@Override
	protected void startingServer(String serverSerialName){
		waitingServer(moduleName,serverSerialName);
	}
}
