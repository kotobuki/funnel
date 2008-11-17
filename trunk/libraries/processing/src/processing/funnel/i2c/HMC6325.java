package processing.funnel.i2c;

import processing.funnel.*;

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
		//TODO arduino以外に対応するときは？

		Arduino ar = (Arduino)conectedModule.system;	
		byte[] bu = {0x76,COM_WRITE,slaveAddress,'G',0x74,0x51};

		ar.sendSysex(bu.length,bu);
		
		byte[] tu = {0x76,COM_WRITE,slaveAddress,'A'};
		
		ar.sendSysex(tu.length,tu);
	}
	
	public void update(){
		//TODO arduino以外に対応するときは？

		Arduino ar = (Arduino)conectedModule.system;
		  byte[] bu = {(byte)0x76,COM_READ,slaveAddress,0x7F,0x02};


		ar.sendSysex(bu.length,bu);
	}
	
	public void enterCalibrationMode(){
		System.out.println("enterCalibrationMode()");
		Arduino ar = (Arduino)conectedModule.system;
		
		byte[] bu = {0x76,COM_WRITE,slaveAddress,'C'};

		ar.sendSysex(bu.length,bu);
	}
	
	public void exitCalibrationMode(){
		System.out.println("exitCalibrationMode()");
		Arduino ar = (Arduino)conectedModule.system;
		byte[] bu = {0x76,COM_WRITE,slaveAddress,'E'};

		ar.sendSysex(bu.length,bu);		
	}
	
	public void receiveData(int regAddress,byte[] data){
		switch(regAddress){
		case 0x7F:
			int ihead = (data[0]<<8) | data[1];
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
