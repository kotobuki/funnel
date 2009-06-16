package funnel.i2c {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	import funnel.i2c.WiiNunchuckEvent;

	/**
	 * This is the class to express a Wii Nunchuck controller
	 *
	 * @author Shigeru Kobayashi
	 */
	public class WiiNunchuck extends I2CDevice implements IEventDispatcher {

		private static const REGISTER:uint = 0x00;

		private static const NUM_BYTES:uint = 6;

		private var _x:Number = 0;

		private var _y:Number = 0;

		private var _z:Number = 0;

		private var _cButton:Number = 0;

		private var _lastCButton:Number = 0;

		private var _zButton:Number = 0;

		private var _lastZButton:Number = 0;

		private var _joystickX:Number = 0;

		private var _joystickY:Number = 0;

		private var _address:uint;

		private var _isReadContinuous:Boolean;

		private var _dispatcher:EventDispatcher;

		/**
		 *
		 * @param ioModule
		 * @param isReadContinuous
		 * @param address
		 *
		 *
		 */
		public function WiiNunchuck(ioModule:*, isReadContinuous:Boolean = true, address:uint = 0x52) {
			super(ioModule, address);

			_address = address;
			_isReadContinuous = isReadContinuous;

			_dispatcher = new EventDispatcher(this);

			// Initiate device: memory address, zero
			_io.sendSysex(I2C_REQUEST, [WRITE, address, 0x40, 0x00]);

			if (_isReadContinuous) {
				_io.sendSysex(I2C_REQUEST, [READ_CONTINUOUS, address, REGISTER, NUM_BYTES]);
			}
		}

		public override function update():void {
			if (!_isReadContinuous) {
				_io.sendSysex(I2C_REQUEST, [READ, address, NUM_BYTES]);
				_io.sendSysex(I2C_REQUEST, [WRITE, address, 0x00]);
			} else {
				throw new ArgumentError("Cannot call update method when Read Continuous is set to true");
			}
		}

		public override function handleSysex(command:uint, data:Array):void {
			if (command != I2C_REPLY) {
				return;
			}

			if (data.length != NUM_BYTES + 2) {
				throw new ArgumentError("Incorrecte number of bytes returned");
				return;
			}

			for (var i:int = 2; i < data.length; i++) {
				data[i] = decodeByte(int(data[i]));
			}

			_joystickX = int(data[2]);
			_joystickY = int(data[3]);
			_x = (int(data[4]) << 2) | ((int(data[7]) >> 2) & 0x03);
			_y = (int(data[5]) << 2) | ((int(data[7]) >> 4) & 0x03);
			_z = (int(data[6]) << 2) | ((int(data[7]) >> 6) & 0x03);

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

		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
			_dispatcher.addEventListener(type, listener, useCapture, priority);
		}

		public function dispatchEvent(evt:Event):Boolean {
			return _dispatcher.dispatchEvent(evt);
		}

		public function hasEventListener(type:String):Boolean {
			return _dispatcher.hasEventListener(type);
		}

		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
			_dispatcher.removeEventListener(type, listener, useCapture);
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
			// divide by 255 to return value between -1.0 and 1.0
			// TODO: use calibration data stored in a controller
			return (_x - 511) / 255;
		}

		/**
		 *
		 *
		 * @return
		 *
		 */
		public function get y():Number {
			// divide by 255 to return value between -1.0 and 1.0
			// TODO: use calibration data stored in a controller
			return (_y - 511) / 255;
		}

		/**
		 *
		 *
		 * @return
		 *
		 */
		public function get z():Number {
			// divide by 255 to return value between -1.0 and 1.0
			// TODO: use calibration data stored in a controller
			return (_z - 511) / 255;
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
			// TODO: use calibration data stored in a controller to normalize
			return _joystickX;
		}

		/**
		 *
		 *
		 * @return
		 *
		 */
		public function get joystickY():Number {
			// TODO: use calibration data stored in a controller to normalize
			return _joystickY;
		}

		private function decodeByte(x:int):int {
			x = (x ^ 0x17) + 0x17;
			return x;
		}
	}
}