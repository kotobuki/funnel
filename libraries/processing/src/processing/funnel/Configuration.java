package processing.funnel;

public final class Configuration{

	int[] portStatus;
	final int moduleID;
	
	IoModule module;
	
	public Configuration(int moduleID, int[] config){
		this.moduleID = moduleID;
		portStatus = config;
		
		//TODO ���W���[����ǉ������Ƃ��A�����ɉ�����
		if(moduleID == GAINER.moduleID){
			module = new GAINER();
		}else if(moduleID == ARDUINO.moduleID){
			module = new ARDUINO();
		}
	}

	
	public void initialize(){
		portStatus = module.initialize(portStatus);
	}
	
	public int[] getPortStatus(){
		return portStatus;
	}
	
	//output [outstart1,outnum1,outstart2,outnum2.....]
	
	public int[] getOutputPortNumber(){
		return module.getOutputPortNumber();
	}
	
	//�Đݒ�͂ł��܂���
	public boolean setDigitalPinMode(int n,int digitalType){
		if(moduleID == ARDUINO.moduleID){
			portStatus[n] = digitalType;
			ARDUINO arduino = (ARDUINO)module;
			return arduino.setDigitalPinMode(n, digitalType);
		}
		return false;
		
	}
	
	
	
	

}
