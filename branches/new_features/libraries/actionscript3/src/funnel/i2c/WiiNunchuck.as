package funnel.i2c {

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	/**
	 * This is the class to express a Wii Nunchuck controller
	 * Reference: http://www.wiili.org/index.php/Wiimote/Extension_Controllers/Nunchuk
	 * @author Shigeru Kobayashi
	 */
	public class WiiNunchuck extends I2CDevice implements IEventDispatcher {

		private static const CALIBRATION_DATA_REGISTER:uint = 0x20;

		private static const NUM_SENSOR_DATA_BYTES:uint = 6;

		private static const SENSOR_DATA_REGISTER:uint = 0x00;

		private var _accelerometer1GRangeX:int = 256;

		private var _accelerometer1GRangeY:int = 256;

		private var _accelerometer1GRangeZ:int = 256;

		private var _accelerometerCenterX:int = 512;

		private var _accelerometerCenterY:int = 512;

		private var _accelerometerCenterZ:int = 512;

		private var _address:uint;

		private var _cButton:Number = 0;

		private var _dispatcher:EventDispatcher;

		private var _isReadContinuous:Boolean;

		private var _joystickCenterX:int = 127;

		private var _joystickCenterY:int = 127;

		private var _joystickNegativeRangeX:int = 96;

		private var _joystickNegativeRangeY:int = 96;

		private var _joystickPositiveRangeX:int = 96;

		private var _joystickPositiveRangeY:int = 96;

		private var _joystickX:Number = 0;

		private var _joystickY:Number = 0;

		private var _lastCButton:Number = 0;

		private var _lastZButton:Number = 0;

		private var _x:Number = 0;

		private var _y:Number = 0;

		private var _z:Number = 0;

		private var _zButton:Number = 0;

		/**
		 *
		 * @param ioModule
		 * @param isReadContinuous
		 * @param address
		 *
		 *
		 */
		public function WiiNunchuck(ioModule:*, isReadContinuous:Boolean = true, address:uint = 0x52) {
			super(ioModule, address, 150); // set I2C delay to 150uS (or higher)

			_address = address;
			_isReadContinuous = isReadContinuous;

			_dispatcher = new EventDispatcher(this);

			// Initiate device: memory address, zero
			_io.sendSysex(I2C_REQUEST, [WRITE, _address, 0x40, 0x00]);

			// Read the Nunchuk's calibration data
			_io.sendSysex(I2C_REQUEST, [READ, _address, CALIBRATION_DATA_REGISTER, 14]);
		}

		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
			_dispatcher.addEventListener(type, listener, useCapture, priority);
		}

		/**
		 *
		 *
		 * @return
		 *
		 */
		public function get cButton():Number {
			return _cButton;
		}

		public function dispatchEvent(evt:Event):Boolean {
			return _dispatcher.dispatchEvent(evt);
		}

		override public function handleSysex(command:uint, data:Array):void {
			if (command != I2C_REPLY) {
				return;
			}

			if (data[1] == SENSOR_DATA_REGISTER) {
				handleData(data);
			} else if (data[1] == CALIBRATION_DATA_REGISTER) {
				handleCalibrationData(data);
				if (_isReadContinuous) {
					_io.sendSysex(I2C_REQUEST, [READ_CONTINUOUS, address, SENSOR_DATA_REGISTER, NUM_SENSOR_DATA_BYTES]);
				}
			}
		}

		public function hasEventListener(type:String):Boolean {
			return _dispatcher.hasEventListener(type);
		}

		/**
		 *
		 *
		 * @return
		 *
		 */
		public function get isCButtonPressed():Boolean {
			return (_cButton == 1);
		}

		/**
		 *
		 *
		 * @return
		 *
		 */
		public function get isZButtonPressed():Boolean {
			return (_zButton == 1);
		}

		/**
		 *
		 *
		 * @return
		 *
		 */
		public function get joystickX():Number {
			return _joystickX;
		}

		/**
		 *
		 *
		 * @return
		 *
		 */
		public function get joystickY():Number {
			return _joystickY;
		}

		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
			_dispatcher.removeEventListener(type, listener, useCapture);
		}

		override public function update():void {
			if (!_isReadContinuous) {
				_io.sendSysex(I2C_REQUEST, [READ, address, NUM_SENSOR_DATA_BYTES]);
				_io.sendSysex(I2C_REQUEST, [WRITE, address, 0x00]);
			} else {
				throw new ArgumentError("Cannot call update method when Read Continuous is set to true");
			}
		}

		public function willTrigger(type:String):Boolean {
			return _dispatcher.willTrigger(type);
		}

		/**
		 *
		 *
		 * @return
		 *
		 */
		public function get x():Number {
			return _x;
		}

		/**
		 *
		 *
		 * @return
		 *
		 */
		public function get y():Number {
			return _y;
		}

		/**
		 *
		 *
		 * @return
		 *
		 */
		public function get z():Number {
			return _z;
		}

		/**
		 *
		 *
		 * @return
		 *
		 */
		public function get zButton():Number {
			return _zButton;
		}

		private function decodeByte(x:int):int {
			x = (x ^ 0x17) + 0x17;
			return x;
		}

		private function handleCalibrationData(data:Array):void {
			for (var i:int = 2; i < data.length; i++) {
				data[i] = decodeByte(int(data[i]));
			}

			_joystickCenterX = int(data[12]);
			_joystickPositiveRangeX = int(data[10]) - _joystickCenterX;
			_joystickNegativeRangeX = _joystickCenterX - int(data[11]);
			_joystickCenterY = int(data[15]);
			_joystickPositiveRangeY = int(data[13]) - _joystickCenterY;
			_joystickNegativeRangeY = _joystickCenterY - int(data[14]);

			_accelerometerCenterX = (int(data[2]) << 2) + ((int(data[5]) >> 0) & 0x03);
			_accelerometerCenterY = (int(data[3]) << 2) + ((int(data[5]) >> 2) & 0x03);
			_accelerometerCenterZ = (int(data[4]) << 2) + ((int(data[5]) >> 4) & 0x03);
			_accelerometer1GRangeX = (int(data[6]) << 2) + ((int(data[9]) >> 0) & 0x03) - _accelerometerCenterX;
			_accelerometer1GRangeY = (int(data[7]) << 2) + ((int(data[9]) >> 2) & 0x03) - _accelerometerCenterY;
			_accelerometer1GRangeZ = (int(data[8]) << 2) + ((int(data[9]) >> 4) & 0x03) - _accelerometerCenterZ;
		}

		private function handleData(data:Array):void {
			if (data.length != NUM_SENSOR_DATA_BYTES + 2) {
				throw new ArgumentError("Incorrecte number of bytes returned");
				return;
			}

			for (var i:int = 2; i < data.length; i++) {
				data[i] = decodeByte(int(data[i]));
			}

			_joystickX = normalize(int(data[2]), _joystickCenterX, _joystickPositiveRangeX, _joystickNegativeRangeX);
			_joystickY = normalize(int(data[3]), _joystickCenterY, _joystickPositiveRangeY, _joystickNegativeRangeY);
			_x = normalize((int(data[4]) << 2) | ((int(data[7]) >> 2) & 0x03), _accelerometerCenterX, _accelerometer1GRangeX, _accelerometer1GRangeX);
			_y = normalize((int(data[5]) << 2) | ((int(data[7]) >> 4) & 0x03), _accelerometerCenterY, _accelerometer1GRangeY, _accelerometer1GRangeY);
			_z = normalize((int(data[6]) << 2) | ((int(data[7]) >> 6) & 0x03), _accelerometerCenterZ, _accelerometer1GRangeZ, _accelerometer1GRangeZ);

			_zButton = (int(data[7]) & 0x01) ? 0 : 1;
			_cButton = (int(data[7]) & 0x02) ? 0 : 1;

			dispatchEvent(new Event(Event.CHANGE));
			dispatchEvent(new WiiNunchuckEvent(WiiNunchuckEvent.JOYSTICK_CHANGE));
			dispatchEvent(new WiiNunchuckEvent(WiiNunchuckEvent.ACCELEROMETER_CHANGE));

			if (_lastCButton != _cButton) {
				if (_cButton == 1) {
					dispatchEvent(new WiiNunchuckEvent(WiiNunchuckEvent.C_BUTTON_PRESS));
				} else {
					dispatchEvent(new WiiNunchuckEvent(WiiNunchuckEvent.C_BUTTON_RELEASE));
				}
			}

			if (_lastZButton != _zButton) {
				if (_zButton == 1) {
					dispatchEvent(new WiiNunchuckEvent(WiiNunchuckEvent.Z_BUTTON_PRESS));
				} else {
					dispatchEvent(new WiiNunchuckEvent(WiiNunchuckEvent.Z_BUTTON_RELEASE));
				}
			}

			_lastCButton = _cButton;
			_lastZButton = _zButton;
		}

		private function normalize(input:int, center:int, positiveRange:int, negativeRange:int):Number {
			return (input > center) ? ((input - center) / positiveRange) : ((input - center) / negativeRange);
		}

	}
}