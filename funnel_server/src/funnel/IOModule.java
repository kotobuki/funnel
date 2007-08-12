/**
 * 
 */
package funnel;

import java.util.Enumeration;
import java.util.concurrent.LinkedBlockingQueue;

import com.illposed.osc.OSCMessage;

import gnu.io.CommPortIdentifier;

/**
 * The abstract class for I/O module classes
 * 
 * @author Shigeru Kobayashi
 * @see GainerIO
 */
public abstract class IOModule {
	public final static Integer PORT_AIN = new Integer(0);
	public final static Integer PORT_DIN = new Integer(1);
	public final static Integer PORT_AOUT = new Integer(2);
	public final static Integer PORT_DOUT = new Integer(3);

	protected LinkedBlockingQueue<OSCMessage> notifierQueue;
	protected FunnelServer parent;

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
