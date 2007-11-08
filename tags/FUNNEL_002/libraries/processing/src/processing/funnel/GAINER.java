package processing.funnel;

import java.util.Arrays;

public final class GAINER implements IoModule{

	public static final int moduleID = 0x1000;//
	//出力ポートのはじめの番号と数の列挙
	///[outstart1,outnum1,outstart2,outnum2.....]
	private int[] outputPortNumber;
	
	
	private static final int[] conf1 = {
		PORT_AIN, PORT_AIN, PORT_AIN, PORT_AIN,
		PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN,
		PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT,
		PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT,
		PORT_DOUT, PORT_DIN,  // LED, BUTTON
	};
	public static final Configuration CONFIGURATION_1 = new Configuration(moduleID,conf1);

	
	private static final int[] conf2 = {
    PORT_AIN, PORT_AIN, PORT_AIN, PORT_AIN,
    PORT_AIN, PORT_AIN, PORT_AIN, PORT_AIN,
    PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT,
    PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT,
    PORT_DOUT, PORT_DIN,  // LED, BUTTON
	};
	public static final Configuration CONFIGURATION_2 = new Configuration(moduleID,conf2);
	
	
	public static final int[] conf3 = {
		PORT_AIN, PORT_AIN, PORT_AIN, PORT_AIN,
		PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN,
    PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT,
    PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT,
    PORT_DOUT, PORT_DIN,  // LED, BUTTON		
	};
	public static final Configuration CONFIGURATION_3 = new Configuration(moduleID,conf3);
	
		
	public static final int[] conf4 = {
		 PORT_AIN, PORT_AIN, PORT_AIN, PORT_AIN,
		 PORT_AIN, PORT_AIN, PORT_AIN, PORT_AIN,
		 PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT,
		 PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT,
		 PORT_DOUT, PORT_DIN,  // LED, BUTTON	
	};
	public static final Configuration CONFIGURATION_4 = new Configuration(moduleID,conf4);
	
	
	public static final int[] conf5 = {
		 PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN,
		 PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN,
		 PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN,
		 PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN,	
	};
	public static final Configuration CONFIGURATION_5 = new Configuration(moduleID,conf5);
	

	public static final int[] conf6 = {
		 PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT,
		 PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT,
		 PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT,
		 PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT,		
	};
	public static final Configuration CONFIGURATION_6 = new Configuration(moduleID,conf6);
	
	
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
	public static final Configuration CONFIGURATION_7 = new Configuration(moduleID,conf7);
	
	
	public static final int[] conf8 = {
		 PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN,
		 PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN,
		 PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT,
		 PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT,	
	};
	public static final Configuration CONFIGURATION_8 = new Configuration(moduleID,conf8);
	
	
	//ポートの機能
	public static int LED;
	public static int button;
	public static int analogInput[];
	public static int digitalInput[];
	public static int analogOutput[];
	public static int digitalOutput[];
	

	public GAINER(){}
	
	public int[] initialize(int[] config){
		if(Arrays.equals(config,conf1)){
			int[] nums = {8,4,12,4,16,1};
			outputPortNumber = nums;
			
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
			
		}else if(Arrays.equals(config,conf2)){
			int[] nums = {8,4,12,4,16,1};
			outputPortNumber = nums;
			
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
		}else if(Arrays.equals(config,conf3)){
			int[] nums = {8,8,16,1};
			outputPortNumber = nums;
			
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
		}else if(Arrays.equals(config,conf4)){
			int[] nums = {8,8,16,1};
			outputPortNumber = nums;
			
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
		}else if(Arrays.equals(config,conf5)){
			int[] nums = {};
			outputPortNumber = nums;
			
			int[] ain = {};
			int[] din = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15};
			int[] aout = {};
			int[] dout = {};
			
			analogInput = ain;
			digitalInput = din;
			analogOutput = aout;
			digitalOutput = dout;
	
		}else if(Arrays.equals(config,conf6)){
			int[] nums = {0,16};
			outputPortNumber = nums;
			
			int[] ain = {};
			int[] din = {};
			int[] aout = {};
			int[] dout = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15};
			
			analogInput = ain;
			digitalInput = din;
			analogOutput = aout;
			digitalOutput = dout;

			
		}else if(Arrays.equals(config,conf7)){
			int[] nums = {0,64};
			outputPortNumber = nums;
			
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

			
		}else if(Arrays.equals(config,conf8)){
			int[] nums = {8,8};
			outputPortNumber = nums;
			
			int[] ain = {};
			int[] din = {0,1,2,3,4,5,6,7};
			int[] aout = {};
			int[] dout = {8,9,10,11,12,13,14,15};
			
			analogInput = ain;
			digitalInput = din;
			analogOutput = aout;
			digitalOutput = dout;

		}
		return config;
	}

	public int[] getOutputPortNumber(){
		return outputPortNumber;
	}

	
}
