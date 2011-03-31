package funnel.i2c {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import funnel.i2c.I2CDevice;
	
	/**
	 * This is the class to express an InvenSense ITG3200 3-axis MEMS gyro
	 *
	 * @author Jeff Hoefs 3/1/11
	 * based in part on Filipe Vieira'a ITG3200 library for Arduino
	 */
	
	public class GyroITG3200 extends I2CDevice implements IEventDispatcher {

		public static const DEVICE_ID:uint = 0x69; // if pin 9 is tied to VCC, else 0x68 if pin 9 tied to GND
		private static const STARTUP_DELAY:uint = 70;
		private static const TOTAL_SAMPLES:uint = 500;
		
		// registers
		private static const SMPLRT_DIV:uint = 0x15;
		private static const DLPF_FS:uint = 0x16;
		private static const INT_CFG:uint = 0x17;
		private static const GYRO_XOUT:uint = 0x1D;
		private static const GYRO_YOUT:uint = 0x1F;
		private static const GYRO_ZOUT:uint = 0x21;
		private static const PWR_MGM:uint = 0x3E;
		
		private static const NUM_BYTES:uint = 6;	
		
		private var _x:Number = 0;
		private var _y:Number = 0;
		private var _z:Number = 0;
		
		private var _address:uint;
		private var _autoStart:Boolean;
		private var _autoCalibrate:Boolean;
		private var _isReading:Boolean = false;
		private var _isCalibrating:Boolean = false;
		
		private var _totalSamples:uint;
		private var _sampleCount:uint = 0;
		private var _lastProgressValue:int = -1;
		private var _tempOffsets:Object;
		private var _offsets:Object;
		private var _polarities:Object;
		private var _gains:Object;
		
		private var _startupTimer:Timer;
		
		private var _dispatcher:EventDispatcher;
		
		// debug mode 		
		private var _debugMode : Boolean = false;	
		
		/**
		 * @param	ioModule	A funnel io module such as an instance of a fio or arduino
		 * @param	autoStart	True if read continuous mode should start automatically upon instantiation (default is true)
		 * @param	autoCalibrate	True if calibration routine should start automatically upon instantiation (default is false)
		 * @param	address		The i2c address of the accelerometer (default is 0x69)
		 */
		public function GyroITG3200(ioModule:*, autoStart:Boolean = true, autoCalibrate:Boolean = false, address:uint = DEVICE_ID) {
			super(ioModule, address);
			
			_address = address;
			
			_autoStart = autoStart;
			_autoCalibrate = autoCalibrate;
			
			_dispatcher = new EventDispatcher(this);
			
			_gains = {x:1.0, y:1.0, z:1.0};
			_offsets = {x:0.0, y:0.0, z:0.0};
			_polarities = {x:0, y:0, z:0};
			
			setRevPolarity(false, false, false);
			
			init();
			
		}
		
		// to do: allow user to choose alternative settings?
		private function init():void {			
			// set fast sample rate divisor = 0
			_io.sendSysex(I2C_REQUEST, [WRITE, _address, SMPLRT_DIV, 0x00]);
			
			// set range to +-2000 degrees/sec and low pass filter bandwidth to 256Hz and internal sample rate to 8kHz
			_io.sendSysex(I2C_REQUEST, [WRITE, _address, DLPF_FS, 0x18]);
			
			// use internal oscillator
			_io.sendSysex(I2C_REQUEST, [WRITE, _address, PWR_MGM, 0x00]);
			
			// enable ITG ready bit and raw data ready bit
			// note: this is probably not necessary if interrupts aren't used
			_io.sendSysex(I2C_REQUEST, [WRITE, _address, INT_CFG, 0x05]);
			
			_startupTimer = new Timer(STARTUP_DELAY, 1);
			_startupTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onGyroReady);
			_startupTimer.start();
		}
		
		// not currently used, but convenient method to set individual register bits
		private function setRegisterBit(regAddress:uint, bitPos:uint, state:Boolean):void {
			var value:uint;
			
			if (state) {
				value |= (1 << bitPos);
			} else {
				value &= ~(1 << bitPos);
			}
			_io.sendSysex(I2C_REQUEST, [WRITE, _address, regAddress, value]);
		}			
		
		private function onGyroReady(evt:TimerEvent):void {
			_startupTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onGyroReady);
			
			dispatchEvent(new GyroEvent(GyroEvent.GYRO_READY));
			if (_autoStart && !_autoCalibrate) {
				startReading();
			}
			else if (_autoCalibrate) {
				calibrate();
			}
			
		}
		
		/**
		 * Routine to calibrate x, y, and z values to approximately zero.
		 * PLEASE NOTE: The calibration method may take several seconds to complete. Listen for
		 * <code>GyroEvent.CALIBRATION_PROGRESS</code> to get current progress, reading the 
		 * <code>progress</code> property of the GyroEvent.
		 * 
		 * @param	totalSamples	total number of samples to use for calibration (default = 500)
		 * 
		 */
		public function calibrate(totalSamples:uint = TOTAL_SAMPLES):void {
			_isCalibrating = true;
			_totalSamples = totalSamples
			
			_tempOffsets = {x:0, y:0, z:0};
			
			debug("calibrating...");
			
			for (var i:int = 0; i < _totalSamples; i++) {
				update();
			}
			
		}
		
		/**
		 * set the polarity of the x, y, and z output values
		 * 
		 * @param	xPol	polarity of the x axis
		 * @param	yPol	polarity of the y axis
		 * @param	zPol	polarity of the z axis
		 */
		public function setRevPolarity(xPol:Boolean, yPol:Boolean, zPol:Boolean):void {
			_polarities.x = xPol ? -1 : 1;
			_polarities.y = yPol ? -1 : 1;
			_polarities.z = zPol ? -1 : 1;
		}
		
		/**
		 * offset the x, y, or z output by the respective input value
		 */
		public function setOffsets(xOffset:Number, yOffset:Number, zOffset:Number):void {
			_offsets.x = xOffset;
			_offsets.y = yOffset;
			_offsets.z = zOffset;
		}
		
		/**
		 * set the gain value for the x, y, or z output
		 */
		public function setGains(xGain:Number, yGain:Number, zGain:Number):void {
			_gains.x = xGain;
			_gains.y = yGain;
			_gains.z = zGain;
		}		
		
		/**
		 * start continuous reading of the sensor
		 */
		public function startReading():void {
			if (!_isReading) {
				_isReading = true;
				_io.sendSysex(I2C_REQUEST, [READ_CONTINUOUS, _address, GYRO_XOUT, 6]);				
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
		 * sends read request to accelerometer and updates accelerometer values.
		 */
		public override function update():void {
			
			if (_isReading) {
				stopReading();
			}
			
			// read data: contents of X, Y, and Z registers
			_io.sendSysex(I2C_REQUEST, [READ, _address, GYRO_XOUT, 6]);
		}
		
		/**
		 * @private
		 */
		public override function handleSysex(command:uint, data:Array):void {
			
			if (command != I2C_REPLY) {
				return;
			}
			
			switch (Number(data[1])) {
				case GYRO_XOUT:
					
					readGyro(data);
					
					if (_isCalibrating) {
						calibrationRoutine();
					} else {
						dispatchEvent(new Event(Event.CHANGE));
					}
					
					break;
				default:
					debug("Got unexpected register data");
					break;
			}
			
		}
		
		private function calibrationRoutine():void {
			_tempOffsets.x += x;
			_tempOffsets.y += y;
			_tempOffsets.z += z;
			
			var progress:uint = (_sampleCount / _totalSamples) * 100;
			
			if (progress > _lastProgressValue) {
				dispatchEvent(new GyroEvent(GyroEvent.CALIBRATION_PROGRESS, progress));
			}
			_lastProgressValue = progress;
			if (_sampleCount++ == _totalSamples) {
				
				_isCalibrating = false;
				
				setOffsets(-_tempOffsets.x / _totalSamples, -_tempOffsets.y / _totalSamples, -_tempOffsets.z / _totalSamples);
				
				dispatchEvent(new GyroEvent(GyroEvent.CALIBRATION_COMPLETE));
				debug("calibration complete");
			
				if (_autoStart) {
					startReading();
				}
			}			
		}
		
		private function readGyro(data:Array):void {
			
			var x_val:int, y_val:int, z_val:int;
			
			if (data.length != NUM_BYTES + 2) {
				throw new ArgumentError("Incorrecte number of bytes returned");
				return;
			}
			
			x_val = (int(data[2]) << 8) | (int(data[3]));
			y_val = (int(data[4]) << 8) | (int(data[5]));
			z_val = (int(data[6]) << 8) | (int(data[7]));
			
			if(x_val >> 15) {
				_x = ((x_val ^ 0xFFFF) + 1) * -1;
			} else _x = x_val;
			if(y_val >> 15) {
				_y = ((y_val ^ 0xFFFF) + 1) * -1;
			} else _y = y_val;
			if(z_val >> 15) {
				_z = ((z_val ^ 0xFFFF) + 1) * -1;
			} else _z = z_val;

		}
		
		/**
		 * Get state of continuous read mode. If true, continuous read mode
		 * is enabled, if false, it is disabled.
		 */
		public function get isRunning():Boolean {
			return _isReading;
		}
		
		/** returns raw x output value from sensor
		 */
		public function get rawX():Number {
			return _x;
		}
		
		/** returns raw y output value from sensor
		 */
		public function get rawY():Number {
			return _y;
		}
		
		/** returns raw z output value from sensor
		 */
		public function get rawZ():Number {
			return _z;
		}
		
		/** returns the x axis output value in degrees
		 */
		public function get x():Number {
			return _x / 14.375 * _polarities.x * _gains.x + _offsets.x;
		}
		
		/** returns the y axis output value in degrees
		 */
		public function get y():Number {
			return _y / 14.375 * _polarities.y * _gains.y + _offsets.y;
		}
		
		/** returns the z axis output value in degrees
		 */
		public function get z():Number {
			return _z / 14.375 * _polarities.z * _gains.z + _offsets.z;
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