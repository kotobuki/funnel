package processing.funnel.i2c;

import processing.funnel.IOModule;

/**
 * @author endo
 * @version 1.0
 * 
 */
public abstract class I2CDevice {
	
	public static final byte COM_I2C_REQUEST = 0x76;
	public static final byte COM_I2C_REPLY = 0x77;
	
	protected final byte COM_WRITE = 0;
	protected final byte COM_READ = 1;
	protected final byte COM_READ_CONTINUOUS = 2;
	protected final byte COM_STOP_READING = 3;

	protected IOModule conectedModule;

	
	public I2CDevice(IOModule io){
		conectedModule = io;
	}
	


	
}
