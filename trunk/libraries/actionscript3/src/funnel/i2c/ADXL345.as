package funnel.i2c {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import funnel.i2c.I2CDevice;
	
	/**
	 * This is the class to express an Analog Devices ADXL345 3-axis accelerometer
	 *
	 * @author Jeff Hoefs 3/1/11
	 */
	public class ADXL345 extends I2CDevice implements IEventDispatcher {
		
		public static const RANGE_2G:Number = 2;
		public static const RANGE_4G:Number = 4;
		public static const RANGE_8G:Number = 8;
		public static const RANGE_16G:Number = 16;
		public static const DEVICE_ID:uint = 0x53;
		public static const DEFAULT_SENSITIVITY:Number = 0.00390625;
		
		private static const POWER_CTL:uint = 0x2D;
		private static const DATAX0:uint = 0x32;
		private static const DATA_FORMAT:uint = 0x31;
		private static const OFSX:uint = 0x1E;
		private static const OFSY:uint = 0x1F;
		private static const OFSZ:uint = 0x20;
		
		private static const ALL_AXIS:uint = DATAX0 | 0x80;
		private static const NUM_BYTES:uint = 6;		
		
		private var _x:Number = 0;
		private var _y:Number = 0;
		private var _z:Number = 0;
		
		private var _dynamicRange:Number;
		private var _sensitivity:Object;
		private var _offset:Object;
		
		private var _address:uint;
		private var _isReading:Boolean = false;
		
		private var _dispatcher:EventDispatcher;
		
		// debug mode 		
		private var _debugMode : Boolean = false;
		
		/**
		 * @param	ioModule	A funnel io module such as an instance of a fio or arduino
		 * @param	autoStart	True if read continuous mode should start automatically upon instantiation (default is false)
		 * @param	address		The i2c address of the accelerometer (default is 0x53)
		 * @param	range		The dynamic range selection in Gs (options RANGE_2G, RANGE_4G, RANGE_8G, RANGE_16G). Default is RANGE_2G.
		 */
		public function ADXL345(ioModule:*, autoStart:Boolean = false, address:uint = DEVICE_ID, range:Number = RANGE_2G) {
			super(ioModule, address);
			
			_address = address;
			_dynamicRange = range;
			
			_dispatcher = new EventDispatcher(this);
			
			// default value = 1/256
			_sensitivity = {x:DEFAULT_SENSITIVITY, y:DEFAULT_SENSITIVITY, z:DEFAULT_SENSITIVITY};
			
			_offset = {x:0, y:0, z:0};
			
			/* Initiate device */
			powerOn();
			
			// sets the dynamic range and sets the full_res bit
			setRangeAndFullRes(_dynamicRange);
			
			if(autoStart) {
				startReading();
			}
		}
		
		private function setRangeAndFullRes(range:Number):void {
			
			var setting:uint;
			
			switch (range) {
				case 2:
					setting = 0x00;
					break;
				case 4:
					setting = 0x01;
					break;
				case 8:
					setting = 0x02;
					break;
				case 16:
					setting = 0x03;
					break;
				default:
					setting = 0x00;
					break;
			}
			
			// set full scale bit (3) and range bits (0 - 1)
			setting |= (0x08 & 0xEC);
			_io.sendSysex(I2C_REQUEST, [WRITE, _address, DATA_FORMAT, setting]);
		}
		
		/**
		 * start continuous reading of the sensor
		 */		
		public function startReading():void {
			if (!_isReading) {
				_isReading = true;
				_io.sendSysex(I2C_REQUEST, [READ_CONTINUOUS, _address, ALL_AXIS, 6]);				
			}
		}
		
		/**
		 * stop continuous reading of the sensor
		 */			
		public function stopReading():void {
			_isReading = false;
			_io.sendSysex(I2C_REQUEST, [STOP_READING, _address]);
		}
		
		/**
		 * offset the x, y, or z axis output by the respective input value
		 */		
		public function setAxisOffset(xVal:int, yVal:int, zVal:int):void {
			// store values so we can retrieve via getAxisOffset
			_offset.x = xVal;
			_offset.y = yVal;
			_offset.z = zVal;
			
			_io.sendSysex(I2C_REQUEST, [WRITE, _address, OFSX, xVal]);
			_io.sendSysex(I2C_REQUEST, [WRITE, _address, OFSY, yVal]);
			_io.sendSysex(I2C_REQUEST, [WRITE, _address, OFSZ, zVal]);
		}
		
		/**
		 * get the value of the x, y, and z axis offset
		 */
		public function getAxisOffset():Object {
			// will trace values if debug mode is enabled
			_io.sendSysex(I2C_REQUEST, [READ, _address, OFSX, 1]);
			_io.sendSysex(I2C_REQUEST, [READ, _address, OFSY, 1]);
			_io.sendSysex(I2C_REQUEST, [READ, _address, OFSZ, 1]);
			
			// return the locally stored values because it is not possible
			// without a more elaborate design to get i2c read values
			// in a single call
			return _offset;
		}
		
		private function powerOn():void {
			// standby mode
			_io.sendSysex(I2C_REQUEST, [WRITE, _address, POWER_CTL, 0]);
			
			// set measure bit
			setRegisterBit(POWER_CTL, 3, true);
		}
		
		private function setRegisterBit(regAddress:uint, bitPos:uint, state:Boolean):void {
			var value:uint;
			
			if (state) {
				value |= (1 << bitPos);
			} else {
				value &= ~(1 << bitPos);
			}
			_io.sendSysex(I2C_REQUEST, [WRITE, _address, regAddress, value]);
		}		
		
		/** 
		 * Sends read request to accelerometer and updates accelerometer values.
		 */
		public override function update():void {
			
			if(_isReading) {
				stopReading();	
			}
			// read data: contents of X, Y, and Z registers
			_io.sendSysex(I2C_REQUEST, [READ, _address, ALL_AXIS, 6]);
		}
		
		/**
		 * @private
		 */
		public override function handleSysex(command:uint, data:Array):void {
			
			if (command != I2C_REPLY) {
				return;
			}
			
			switch (Number(data[1])) {
				case ALL_AXIS:
					readAccel(data);
					break;
				case OFSX:
					debug("offset x = " + data[2]);
					break;
				case OFSY:
					debug("offset y = " + data[2]);
					break;
				case OFSZ:
					debug("offset z = " + data[2]);
					break;
			}
			
		}
		
		private function readAccel(data:Array):void {
			
			var x_val:int, y_val:int, z_val:int;
			
			if (data.length != NUM_BYTES + 2) {
				throw new ArgumentError("Incorrecte number of bytes returned");
				return;
			}
			
			x_val = (int(data[3]) << 8) | (int(data[2]));
			y_val = (int(data[5]) << 8) | (int(data[4]));
			z_val = (int(data[7]) << 8) | (int(data[6]));
			
			if(x_val >> 15) {
				_x = ((x_val ^ 0xFFFF) + 1) * -1;
			} else _x = x_val;
			if(y_val >> 15) {
				_y = ((y_val ^ 0xFFFF) + 1) * -1;
			} else _y = y_val;
			if(z_val >> 15) {
				_z = ((z_val ^ 0xFFFF) + 1) * -1;
			} else _z = z_val;
			
			dispatchEvent(new Event(Event.CHANGE));			
		}
		
		/**
		 * Get state of continuous read mode. If true, continuous read mode
		 * is enabled, if false, it is disabled.
		 */
		public function get isRunning():Boolean {
			return _isReading;
		}		
		
		/** returns the accelerometer dynamic range in Gs (either 2G, 4G, 8G, or 16G for this sensor).
		 */
		public function get dynamicRange():Number {
			return _dynamicRange;
		}
		
		/** returns raw x acceleration value from sensor
		 */
		public function get rawX():Number {
			return _x;
		}
		
		/** returns raw y acceleration value from sensor
		 */
		public function get rawY():Number {
			return _y;
		}
		
		/** returns raw z acceleration value from sensor
		 */
		public function get rawZ():Number {
			return _z;
		}
		
		/** returns the acceleration value in Gs (9.8m/sec^2) along the x-axis
		 */
		public function get x():Number {
			// return acceleration in Gs
			return _x * _sensitivity.x;
		}
		
		/** returns the acceleration value in Gs (9.8m/sec^2) along the y-axis
		 */
		public function get y():Number {
			// return acceleration in Gs
			return _y * _sensitivity.y;
		}
		
		/** returns the acceleration value in Gs (9.8m/sec^2) along the z-axis
		 */
		public function get z():Number {
			// return acceleration in Gs
			return _z * _sensitivity.z;
		}
		
		/**
		 * set the sensitivity value for an axis (default value = 0.00390625)
		 */
		public function set sensitivityX(value:Number):void {
			_sensitivity.x = value;
		}
		
		public function set sensitivityY(value:Number):void {
			_sensitivity.y = value;
		}
		
		public function set sensitivityZ(value:Number):void {
			_sensitivity.z = value;
		}
		
		/**
		 * get the sensitivity value for an axis
		 */
		public function get sensitivityX():Number {
			return _sensitivity.x;
		}
		
		public function get sensitivityY():Number {
			return _sensitivity.y;
		}
		
		public function get sensitivityZ():Number {
			return _sensitivity.z;
		}		
		
		/* implement EventDispatcher */
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void{
			_dispatcher.addEventListener(type, listener, useCapture, priority);
		}
		
		public function dispatchEvent(evt:Event):Boolean{
			return _dispatcher.dispatchEvent(evt);
		}
		
		public function hasEventListener(type:String):Boolean{
			return _dispatcher.hasEventListener(type);
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void{
			_dispatcher.removeEventListener(type, listener, useCapture);
		}
		
		public function willTrigger(type:String):Boolean {
			return _dispatcher.willTrigger(type);
		}
		
		// for debugging 
		private function debug ( str:String ) : void {
			if ( _debugMode ) {
				trace(str); 
			}
		}		
	}
}