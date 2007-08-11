/**
 * 
 */
package funnel;

import gnu.io.CommPortIdentifier;

import java.util.Enumeration;

/**
 * The abstract class for I/O module classes
 * 
 * @author Shigeru Kobayashi
 * @see GainerIO
 */
public abstract class IOModule {
	/**
	 * Get the name of the first I/O module
	 * 
	 * @return The serial port name of the first I/O module if found
	 */
	static public String getSerialPortName() {
		String dname = null;

		try {
			Enumeration portList = CommPortIdentifier.getPortIdentifiers();
			while (portList.hasMoreElements()) {
				CommPortIdentifier portId = (CommPortIdentifier) portList
						.nextElement();
				if (portId.getPortType() == CommPortIdentifier.PORT_SERIAL) {

					String pname = portId.getName();
					if (pname.startsWith("/dev/cu.usbserial-")) {
						dname = pname;
					} else if (pname.startsWith("COM")) {
						dname = "COM3";
					}
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}

		return dname;
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
	 * Stop polling
	 */
	abstract public void stopPolling();
}
