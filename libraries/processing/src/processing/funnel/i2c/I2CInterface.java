package processing.funnel.i2c;

/**
 * @author endo
 * @version 1.0
 * 
 */
public interface I2CInterface {

	
	public abstract String getName();
	public int getSlaveAddress();
	public abstract void receiveData(int registerAddress,byte[] data);
}
