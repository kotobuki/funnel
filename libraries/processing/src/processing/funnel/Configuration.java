package processing.funnel;

import java.util.Vector;

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
	
	//new ÇÃå„Å@çƒê›íËÇÕÇ≈Ç´Ç‹ÇπÇÒ
	public boolean setDigitalPinMode(int n,int digitalType){
		if(moduleName.equalsIgnoreCase(ARDUINO.moduleName)){
			portStatus[ARDUINO._digitalPin[n]] = digitalType;
			return true;
		}
		return false;
		
	}
	
	
	
	

}
