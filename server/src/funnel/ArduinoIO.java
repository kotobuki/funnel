/**
 * A hardware abstraction layer for the Arduino I/O board with Firmata v1.0 firmware
 * 
 * References:
 * Erik Sjödin's implementation for ActionScript 3
 * http://www.eriksjodin.net/blog/index.php/arduino-for-flash/
 * 
 * @see http://www.arduino.cc/playground/Interfacing/Firmata
 * @see http://www.arduino.cc/playground/Interfacing/FirmataProtocolDetails
 * @see http://at.or.at/hans/pd/objects.html
 */
package funnel;

import java.io.IOException;
import java.util.concurrent.TimeUnit;

import gnu.io.SerialPortEvent;
import gnu.io.SerialPortEventListener;

/**
 * @author kotobuki
 * 
 */
public class ArduinoIO extends FirmataIO implements SerialPortEventListener {
	private static final int TOTAL_ANALOG_PINS = 8;
	private static final int TOTAL_DIGITAL_PINS = 22;
	private static final int[] PWM_CAPABLE_PINS = new int[] {
		3, 5, 6, 9, 10, 11
	};

	public ArduinoIO(FunnelServer server, String serialPortName, int baudRate) {
		super(TOTAL_ANALOG_PINS, TOTAL_DIGITAL_PINS, PWM_CAPABLE_PINS);
		this.parent = server;
		this.baudRate = baudRate;

		begin(serialPortName, baudRate);
		try {
			capabilitiesReceived.poll(5000, TimeUnit.MILLISECONDS);
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} finally {
			capabilitiesReceived.clear();
		}		
	}

	synchronized public void serialEvent(SerialPortEvent serialEvent) {
		if (serialEvent.getEventType() == SerialPortEvent.DATA_AVAILABLE) {
			try {
				while (input.available() > 0) {
					int inputData = input.read();
					processInput(0, inputData);
				}
			} catch (IOException e) {

			}
		}
	}

	public void reboot() {
		if (port == null) {
			return;
		}
		stopPolling();

		printMessage(Messages.getString("IOModule.Rebooting")); //$NON-NLS-1$

		writeByte(ARD_SYSTEM_RESET);
		sleep(500);

		writeByte(ARD_REPORT_VERSION);
		try {
			firmwareVersionQueue.poll(10000, TimeUnit.MILLISECONDS);
		} catch (InterruptedException e) {
			printMessage("ERROR: Couldn't get a version info after rebooting.");
			e.printStackTrace();
		}
		printMessage(Messages.getString("IOModule.Rebooted")); //$NON-NLS-1$
	}

	public void setConfiguration(Object[] arguments) {
		super.setConfiguration(arguments);

		for (int j = 0; j < dinPinChunks.size(); j++) {
			PortRange range = dinPinChunks.get(j);

			// TODO: Support multiple Arduino I/O boards if needed
			notifyUpdate(0, range.getMin(), range.getCounts());
		}
	}

	void writeByte(int data) {
		if (output == null) {
			return;
		}
		
		try {
			output.write((byte) data);
			output.flush();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}
