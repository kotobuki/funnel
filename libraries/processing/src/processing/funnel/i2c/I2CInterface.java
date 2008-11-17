package processing.funnel.i2c;

public interface I2CInterface {

	
	public abstract String getName();
	public int getSlaveAddress();
	public abstract void receiveData(int registerAddress,byte[] data);
}
