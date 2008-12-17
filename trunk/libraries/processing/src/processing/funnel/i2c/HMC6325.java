package processing.funnel.i2c;

import processing.funnel.*;
/**
 * @author endo
 * @version 1.0
 * 
 */
public class HMC6325 extends I2CDevice implements I2CInterface{

	public String name = "HMC6352";
	
	private byte slaveAddress = 0x21;
	
	
	public float heading;
	
	public int operationalMode = 1;
	
	
	
	public HMC6325(IOModule io){
		super(io);
		
		io.addI2CDevice(this);
		initialize();
	}
	
//	public HMC6325(IOModule io,byte slaveAddress){
//		super(io);
//		this.slaveAddress = slaveAddress;
//		
//		io.addI2CDevice(this);
//		
//		initialize();
//	}
	
	private void initialize(){

		Firmata io = (Firmata)conectedModule.system;
		
		byte[] bu = {COM_I2C_REQUEST,COM_STOP_READING,slaveAddress,'G',0x74,0x51};
		io.sendSysex(conectedModule.getModuleID(),bu.length,bu);
		
		byte[] tu = {COM_I2C_REQUEST,COM_WRITE,slaveAddress,'A'};
		io.sendSysex(conectedModule.getModuleID(),tu.length,tu);

	}
	
	public void update(){

		Firmata io = (Firmata)conectedModule.system;
		  byte[] bu = {COM_I2C_REQUEST,COM_READ,slaveAddress,0x7F,0x02};


		io.sendSysex(conectedModule.getModuleID(),bu.length,bu);
	}
	
	public void beginUpdate(){
		
	}
	
	public void endUpdate(){
	
	}
	
	public void enterCalibrationMode(){
		System.out.println("enterCalibrationMode()");
		Firmata io = (Firmata)conectedModule.system;
		
		byte[] bu = {COM_I2C_REQUEST,COM_WRITE,slaveAddress,'C'};

		io.sendSysex(conectedModule.getModuleID(),bu.length,bu);
	}
	
	public void exitCalibrationMode(){
		System.out.println("exitCalibrationMode()");
		Firmata io = (Firmata)conectedModule.system;
		byte[] bu = {COM_I2C_REQUEST,COM_WRITE,slaveAddress,'E'};

		io.sendSysex(conectedModule.getModuleID(),bu.length,bu);		
	}
	
	public void receiveData(int regAddress,byte[] data){
		switch(regAddress){
		case 0x7F:
			int ihead =  (data[0] & 0xFF)<< 8 | data[1]&0xFF;
			heading = (float)ihead/10;
			break;
		}
	}
	
	
	public int getSlaveAddress(){
		return slaveAddress;
	}
	
	public String getName(){
		return name;
	}
}
