package funnel;

import java.io.IOException;

import gnu.io.SerialPortEvent;

public class FunnelIO extends FirmataIO implements XBeeEventListener {

	private static final int TOTAL_ANALOG_PINS = 8;
	private static final int TOTAL_DIGITAL_PINS = 10;
	private static final int[] PWM_CAPABLE_PINS = new int[] { 8, 9, 10, 11, 12,
			13, 14, 15 };

	private XBee xbee;

	public FunnelIO(FunnelServer server, String serialPortName) {
		super(TOTAL_ANALOG_PINS, TOTAL_DIGITAL_PINS, PWM_CAPABLE_PINS);
		this.parent = server;

		begin(serialPortName);
	}

	void writeByte(int data) {
		// TODO Auto-generated method stub

	}

	public void firmwareVersionEvent(String version) {
		// TODO Auto-generated method stub

	}

	public void modemStatusEvent(int status) {
		// TODO Auto-generated method stub

	}

	public void networkingIdentificationEvent(int my, int sh, int sl, int db,
			String ni) {
		// TODO Auto-generated method stub

	}

	public void panIdEvent(String panId) {
		// TODO Auto-generated method stub

	}

	public void rxIOStatusEvent(int source, int rssi, int ioEnable,
			boolean hasDigitalData, boolean hasAnalogData, int dinStatus,
			float[] analogData) {
		// TODO Auto-generated method stub

	}

	public void rxPacketEvent(int source, int rssi, int options, int[] data) {
		// TODO Auto-generated method stub

	}

	public void sourceAddressEvent(String sourceAddress) {
		// TODO Auto-generated method stub

	}

	public void txStatusMessageEvent(int status) {
		// TODO Auto-generated method stub

	}

	public void unsupportedApiEvent(String apiIdentifier) {
		// TODO Auto-generated method stub

	}

	synchronized public void serialEvent(SerialPortEvent serialEvent) {
		if (serialEvent.getEventType() != SerialPortEvent.DATA_AVAILABLE) {
			return;
		}

		try {
			while (input.available() > 0) {
				int inputData = input.read();
				xbee.processInput(inputData);
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	private void digitalWrite(int address, int pin, int mode) {
		parent.printMessage("digitalWrite(" + pin + ", " + mode + ")");
		int bitMask = 1 << pin;
		// analog inputs
		int outData = 0;

		if (mode == 1) {
			outData = outData | bitMask;
		}

		byte[] rfData = new byte[3];
		rfData[0] = (byte) (0x90 + 0); // TODO: Support port value to handle
		// more than 14 pins
		rfData[1] = (byte) (outData % 128);
		rfData[2] = (byte) (outData >> 7);

		xbee.sendTransmitRequest(address, rfData);
	}

	private void analogWrite(int address, int pin, float value) {
		int intValue = Math.round(value * 255.0f);
		intValue = (intValue < 0) ? 0 : intValue;
		intValue = (intValue > 255) ? 255 : intValue;

		byte[] rfData = new byte[3];
		rfData[0] = (byte) (0xE0 + pin);
		rfData[1] = (byte) (intValue % 128);
		rfData[2] = (byte) (intValue >> 7);

		xbee.sendTransmitRequest(address, rfData);
	}
}
