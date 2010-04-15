package processing.funnel.i2c;

import processing.funnel.Firmata;
import processing.funnel.IOModule;

/**
 * @author endo
 * @version 1.0
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

	protected Firmata io;
	
	public I2CDevice(IOModule io,int readingDelayTime){
		conectedModule = io;
		
		this.io= (Firmata)conectedModule.system;
		
		if(io.powerPinSetting)
		{
            int delayInMicrosecondsLSB = readingDelayTime & 0xFF;
            int delayInMicrosecondsMSB = (readingDelayTime >> 8) & 0xFF;
		
			byte[] bu = {COM_I2C_CONFIG,0x1,(byte)delayInMicrosecondsLSB,(byte)delayInMicrosecondsMSB};
			this.io.sendSysex(conectedModule.getModuleID(),bu.length,bu);
			
			try {
				Thread.sleep(500);
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
		}
	}
	
	public I2CDevice(IOModule io){

		this(io,0);
	}
	


	


	
}
