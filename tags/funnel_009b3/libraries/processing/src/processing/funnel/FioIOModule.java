package processing.funnel;

import processing.core.PApplet;
import processing.funnel.IOModule.Port;


public class FioIOModule extends IOModule {

	public FioIOModule(PApplet parent,int id,Configuration config,String name){
		super(parent,id,config,name);
		
		int[] conf = config.getPortStatus();
		
		port = new Port[conf.length];
		for(int i=0;i<port.length;i++){
			port[i] = new Port(parent,conf[i],i);
		}
	}
	
	
	//Port‚»‚Ì‚à‚Ì‚ð•Ô‚·
	public Port port(int nPort){
		if(nPort<port.length){
			return port[nPort];
		}
		return null;
	}
	
//	public Port digitalPin(int nPort){
//		
//	}
}
