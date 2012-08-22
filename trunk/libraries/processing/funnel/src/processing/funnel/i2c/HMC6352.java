package processing.funnel.i2c;

import processing.funnel.*;
/**
 * @author endo
 * @version 1.1
 * 
 */
public class HMC6352 extends I2CDevice implements I2CInterface{

	public final static String name = "HMC6352";
	
	public final static byte slaveAddress = 0x21;
	
	public float heading;

	
	public HMC6352(IOModule iomodule){
		super(iomodule,slaveAddress, name);
		
		iomodule.addI2CDevice(this);		
		
		initialize();
	}
	
	
	//•K—v‚È‚ç
	private void initialize(){
		
		System.out.println("initialize " + name);
	}
	
	//
	public void beginUpdate(){

		//Query Mode
		beginTransmission();
		send((byte)'G');
		send((byte)0x74);
		send((byte)0x01);
		send((byte)'A');
		endTransmission();
		
		//request data
		//read 2byte from 0x7F
		requestFromRegister(0x7F,2,true);

	}
	
	public void endUpdate(){
	
		stopRequest();
		
	}
	
	public void enterCalibrationMode(){
		//System.out.println("enterCalibrationMode()");
		beginTransmission();
		send((byte)'C');
		endTransmission();
	}
	
	public void exitCalibrationMode(){
		//System.out.println("exitCalibrationMode()");
		beginTransmission();
		send((byte)'E');
		endTransmission();	
	}
	
	public void receiveData(int regAddress,byte[] data){
//		switch(regAddress){
//		case 0x7F:
//			int ihead =  (data[0] & 0xFF)<< 8 | data[1]&0xFF;
//			heading = (float)ihead/10;
//			break;
//		}
		
		int ihead =  (data[0] & 0xFF)<< 8 | data[1]&0xFF;
		heading = (float)ihead/10;
	}

}
