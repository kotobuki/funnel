package processing.funnel.i2c;

import processing.funnel.IOModule;

/**
 * @author endo
 * @version 1.0
 * 
 */
public abstract class I2CDevice {
	
	protected byte COM_WRITE = 0;
	protected byte COM_READ = 1;
	protected byte COM_READ_CONTINUOUS = 2;
	protected byte COM_STOP_READING = 3;

	protected IOModule conectedModule;

	
	public I2CDevice(IOModule io){
		conectedModule = io;
	}
	


	
}
