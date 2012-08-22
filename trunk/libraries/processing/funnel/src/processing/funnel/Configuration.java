package processing.funnel;

import java.util.Vector;

/**
 * @author endo
 * @version 1.1
 * 
 */
public final class Configuration{

	int[] pinsStatus;
	public final int moduleID;
	public final String moduleName;
	
	public boolean powerPinSetting = false;
	
	
	public Vector<Integer> outputPins = new Vector<Integer>();
	
	public Configuration(int moduleID, int[] config,String moduleName){
		this.moduleID = moduleID;
		this.moduleName = moduleName;
		pinsStatus = config;
	}


	
	public int[] getPortStatus(){
		return pinsStatus;
	}
	
	public int getModuleID(){
		return moduleID;
	}
	
	public String getModuleName(){
		return moduleName;
	}
	
	/**
	 * DigitalPinを設定する
	 * （IOSystem作成後再設定はできません）
	 */
	
	public boolean setDigitalPinMode(int n,int pinType){
		
		if(moduleName.equalsIgnoreCase(Arduino.moduleName) || moduleName.equalsIgnoreCase(Fio.moduleName)){
			if(pinType!=IOSystem.PORT_AIN){

				String portType[] = {"ain","din","aout","dout","servo"};
				System.out.println("change pin type[" + n + "] -> " + portType[pinType] );
				pinsStatus[n] = pinType;
				
				return true;
			}
		}
		
		if(moduleName.equalsIgnoreCase(XBee.moduleName)){
			if(pinType!=IOSystem.PORT_AOUT){
				System.out.println("portStatus[]" + n + " type " + pinType );
				pinsStatus[n] = pinType;
				
				return true;
			}
			
		}
		
		return false;
	}
	
	/**
	 * AIN2をGND、AIN3をVCCとして設定する
	 * （IOSystem作成後再設定はできません）
	 */
	public void enablePowerPins(){
		powerPinSetting = true;
		System.out.println("----- power enable");
	}
	
	
	
	

}
