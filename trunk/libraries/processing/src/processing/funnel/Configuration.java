package processing.funnel;

import java.util.Vector;

/**
 * @author endo
 * @version 1.0
 * 
 */
public final class Configuration{

	int[] portStatus;
	final int moduleID;
	final String moduleName;
	
	public Vector outputPorts = new Vector();
	
	public Configuration(int moduleID, int[] config,String moduleName){
		this.moduleID = moduleID;
		this.moduleName = moduleName;
		portStatus = config;
	}


	
	public int[] getPortStatus(){
		return portStatus;
	}
	
	public int getModuleID(){
		return moduleID;
	}
	
	public String getModuleName(){
		return moduleName;
	}
	
	/**
	 * DigitalPinÇê›íËÇ∑ÇÈ
	 * ÅiIOSystemçÏê¨å„çƒê›íËÇÕÇ≈Ç´Ç‹ÇπÇÒÅj
	 */
	
	public boolean setDigitalPinMode(int n,int pinType){
		
		if(moduleName.equalsIgnoreCase(Arduino.moduleName) || moduleName.equalsIgnoreCase(Fio.moduleName)){
			if(pinType!=IOSystem.PORT_AIN){
				System.out.println("portStatus[]" + n + " type " + pinType );
				portStatus[n] = pinType;
				
				return true;
			}
		}
		
		if(moduleName.equalsIgnoreCase(XBee.moduleName)){
			if(pinType!=IOSystem.PORT_AOUT){
				System.out.println("portStatus[]" + n + " type " + pinType );
				portStatus[n] = pinType;
				
				return true;
			}
			
		}
		
		return false;
	}
	
	
	
	

}
