package processing.funnel.i2c;

import java.util.Vector;

import processing.funnel.Firmata;
import processing.funnel.IOModule;

/**
 * @author endo
 * @version 1.1
 * 
 */
public abstract class I2CDevice {
	
	public static final byte COM_I2C_REQUEST = 0x76;
	public static final byte COM_I2C_REPLY = 0x77;
	public static final byte COM_I2C_CONFIG = 0x78;
	
	protected final byte COM_WRITE = 0;
	protected final byte COM_READ = 1;
	protected final byte COM_READ_CONTINUOUS = 2;
	protected final byte COM_STOP_READING = 3;

	protected IOModule conectedModule;

	protected final int slaveAddress;
	protected final String name;
	
	protected Firmata io;
	
	private Vector<Byte> sendBuffer;
	
	public I2CDevice(IOModule iomodule,int slaveAddress,String name, int readingDelayTime){
		conectedModule = iomodule;
		this.slaveAddress = slaveAddress;
		this.name = name;
		
		this.io= (Firmata)conectedModule.system;
		
		System.out.println("--- power " + iomodule.powerPinSetting);
		
		if(iomodule.powerPinSetting)
		{
            int delayInMicrosecondsLSB = readingDelayTime & 0xFF;
            int delayInMicrosecondsMSB = (readingDelayTime >> 8) & 0xFF;

            byte[] bu = {COM_I2C_CONFIG,0x1,(byte)(delayInMicrosecondsLSB&0xFF),(byte)((delayInMicrosecondsLSB>>8)&0xFF),(byte)(delayInMicrosecondsMSB&0xFF),(byte)((delayInMicrosecondsLSB>>8)&0xFF)};
			this.io.sendSysex(conectedModule.getModuleID(),bu.length,bu);

		}
	}
	
	public I2CDevice(IOModule io, int slaveAddress, String name){

		this(io,slaveAddress, name, 1000);
	}
	
	/**
	 * 
	 */
	protected void beginTransmission(){
		sendBuffer = new Vector<Byte>();
		sendBuffer.clear();
	}
	
	/**
	 * 
	 * @param send byte
	 */
	protected void send(byte b){
		sendBuffer.add(b);
	}
	
	/**
	 * 
	 */
	protected void endTransmission(){
		
		byte[] b = new byte[sendBuffer.size()+3];
		b[0] = COM_I2C_REQUEST;
		b[1] = COM_WRITE;
		b[2] = (byte)slaveAddress;
		for(int i=0;i<sendBuffer.size();i++){
			b[i+3] = sendBuffer.elementAt(i);
		}		
		
		this.io.sendSysex(conectedModule.getModuleID(),b.length,b);
	}
	
	/**
	 * 	
	 * @param I2C register 
	 * @param size
	 * @param continuous
	 */
	protected void requestFromRegister(int register, int size, boolean continuous){

		byte[] b = new byte[5];
		b[0] = COM_I2C_REQUEST;
		if(continuous){
			b[1] = COM_READ_CONTINUOUS;
		}else{
			b[1] = COM_READ;
		}
		b[2] = (byte)slaveAddress;
		b[3] = (byte)register;
		b[4] = (byte)size;
		
		this.io.sendSysex(conectedModule.getModuleID(),b.length,b);
		
	}
	
	protected void stopRequest(){
		byte[] b = new byte[3];
		b[0] = COM_I2C_REQUEST;
		b[1] = COM_STOP_READING;
		b[2] = (byte)slaveAddress;

		
		this.io.sendSysex(conectedModule.getModuleID(),b.length,b);		
	}
	
	
	//受信データはこの中で受け取る
	//派生クラスで定義する
	abstract void receiveData(int regAddress,byte[] data);

	
	public int getSlaveAddress(){
		return slaveAddress;
	}
	
	public String getName(){
		return name;
	}
	
}
