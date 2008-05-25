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

import gnu.io.SerialPortEvent;
import gnu.io.SerialPortEventListener;

/**
 * @author kotobuki
 * 
 */
public class ArduinoIO extends FirmataIO implements SerialPortEventListener {
	private static final int TOTAL_ANALOG_PINS = 6;
	private static final int TOTAL_DIGITAL_PINS = 14;
	private static final int[] PWM_CAPABLE_PINS = new int[] { 9, 11, 12, 15,
			16, 17 };

	public ArduinoIO(FunnelServer server, String serialPortName, int baudRate) {
		super(TOTAL_ANALOG_PINS, TOTAL_DIGITAL_PINS, PWM_CAPABLE_PINS);
		this.parent = server;

		begin(serialPortName, baudRate);

		queryVersion();
		firmwareVersionQueue.pop(15000);
		firmwareVersionQueue.clear();
	}

	synchronized public void serialEvent(SerialPortEvent serialEvent) {
		if (serialEvent.getEventType() == SerialPortEvent.DATA_AVAILABLE) {
			try {
				while (input.available() > 0) {
					int inputData = input.read();
					processInput(inputData);
				}
			} catch (IOException e) {

			}
		}
	}

	void writeByte(int data) {
		try {
			output.write((byte) data);
			output.flush();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}
