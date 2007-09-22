package processing.funnel;

public final class Configuration{

	final int[] portStatus;
	final int moduleID;
	
	IoModule module;
	
	public Configuration(int moduleID, int[] config){
		this.moduleID = moduleID;
		portStatus = config;
		
		//TODO ÉÇÉWÉÖÅ[ÉãÇí«â¡ÇµÇΩÇ∆Ç´ÅAÇ±Ç±Ç…â¡Ç¶ÇÈ
		if(moduleID == GAINER.moduleID){
			module = new GAINER();
		}
	}

	
	public void initialize(){
		module.initialize(portStatus);
	}
	
	public int[] getPortStatus(){
		return portStatus;
	}
	
	//output [outstart1,outnum1,outstart2,outnum2.....]
	public int[] getOutputPortNumber(){
		return module.getOutputPortNumber();
	}

}
