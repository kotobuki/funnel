/**
 * 
 */
package funnel;

import java.util.Enumeration;

import gnu.io.CommPortIdentifier;

/**
 * The abstract class for I/O module classes
 * 
 * @author Shigeru Kobayashi
 * @see GainerIO
 * @see ArduinoIO
 * @see XbeeIO
 * @see FunnelIO
 */
public abstract class IOModule {
	public final static Integer PIN_AIN = new Integer(0);
	public final static Integer PIN_DIN = new Integer(1);
	public final static Integer PIN_AOUT = new Integer(2);
	public final static Integer PIN_DOUT = new Integer(3);
	public final static Integer PIN_SERVO = new Integer(4);
	// public final static Integer PIN_SPI = new Integer(5);
	public final static Integer PIN_I2C = new Integer(6);

	protected FunnelServer parent;
	protected boolean isPolling = false;
	protected final Float FLOAT_ZERO = new Float(0.0f);

	protected int baudRate = -1;

	public int getBaudRate() {
		return baudRate;
	}

	/**
	 * Get the name of the first I/O module
	 * 
	 * @return The serial port name of the first I/O module if found
	 */
	static public String getSerialPortName() {
		String theSerialPortName = null;

		try {
			Enumeration<?> portList = CommPortIdentifier.getPortIdentifiers();
			while (portList.hasMoreElements()) {
				CommPortIdentifier portId = (CommPortIdentifier) portList.nextElement();
				if (portId.getPortType() == CommPortIdentifier.PORT_SERIAL) {
					String foundPortName = portId.getName();
					if (foundPortName.startsWith("/dev/cu.usbserial-") || foundPortName.startsWith("/dev/cu.usbmodem")) {
						theSerialPortName = foundPortName;
					} else if (foundPortName.startsWith("COM")) {
						theSerialPortName = "COM3";
					}
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}

		return theSerialPortName;
	}

	/**
	 * Dispose the I/O module
	 */
	abstract public void dispose();

	/**
	 * @param address
	 *            Address of the OSC message
	 * @param arguments
	 *            Arguments to specify range of inputs
	 * @return
	 */
	abstract public Object[] getInputs(String address, Object[] arguments);

	/**
	 * Reboot the I/O module
	 */
	abstract public void reboot();

	/**
	 * Set configuration of the I/O module
	 * 
	 * @param arguments
	 */
	abstract public void setConfiguration(Object[] arguments);

	/**
	 * Set outputs
	 * 
	 * @param arguments
	 */
	abstract public void setOutput(Object[] arguments);

	/**
	 * Set polling
	 * 
	 * @param arguments
	 */
	abstract public void setPolling(Object[] arguments);

	/**
	 * Start polling
	 */
	abstract public void startPolling();

	/**
	 * Stop polling
	 */
	abstract public void stopPolling();

	protected void printMessage(String msg) {
		parent.printMessage(msg);
	}

	/**
	 * Send system exclusive messages
	 * 
	 * @param arguments
	 */
	abstract public void sendSystemExclusiveMessage(Object[] arguments);

	/**
	 * @param msec
	 *            sleep time in milliseconds
	 */
	protected synchronized void sleep(long msec) {
		try {
			wait(msec);
		} catch (InterruptedException e) {
		}
	}

}
