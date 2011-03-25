package funnel
{
	/**
	 * Use this class to configure the IO module. Configuration sets up by an argument of 
	 * IOSystem constructor in order to decide at a stage of starting communication with
	 * the IOModule.
	 * 
	 * <p>I/Oモジュールのコンフィギュレーションを設定するためのクラスです。コンフィギュレーションはI/Oモジュールとの通信を開始する段階で決定する必要があるため、IOSystemのコンストラクタの引数で指定します。</p>
	 * @see IOSystem#IOSystem()
	 */
	public class Configuration
	{
		/**
		* Gainer.analogInput an array of the analog input pin numbers
		* @see Gainer#analogInput
		*/
		public var ainPins:Array;

		/**
		* Gainer.digitalInput an array of the digital input pin numbers
		* @see Gainer#digitalInput
		*/
		public var dinPins:Array;

		/**
		* Gainer.analogOutput an array of the analog output pin numbers
		* @see Gainer#analogOutput
		*/
		public var aoutPins:Array;

		/**
		* Gainer.digitalOutput an array of the digital output pin numbers
		* @see Gainer#digitalOutput
		*/
		public var doutPins:Array;

		public var servoPins:Array;

		/**
		* Gainer.button the Pin object of the on-board button
		* @see Gainer#button
		*/
		public var button:uint;

		/**
		* Gainer.led the Pin object for the on-board LED
		* @see Gainer#led
		*/
		public var led:uint;

		/**
		* Arduino.analogPin an array of the analog input pin numbers
		* @see Arduino#analogPin
		*/
		public var analogPins:Array;

		/**
		* Arduino.digitalPin an array of the digital input pin numbers
		* @see Arduino#digitalPin
		*/
		public var digitalPins:Array;

		/**
		* pin type (AIN、DIN、AOUT、DOUT) array
		* @see Pin#DIN
		* @see Pin#DOUT
		* @see Pin#AIN
		* @see Pin#AOUT
		* @see Pin#PWM
		* @see Pin#SERVO
		*/
		public var config:Array;

		/**
		* module ID
		*/
		public var moduleID:uint;

		private var _powerPinsEnabled:Boolean = false;

		/**
		 * Set a digital pin to input, output or PWM mode (DIN, DOUT, AIN, or PWM)
		 * 
		 * <p>デジタルピンのモードを設定します。Arduino、Fio、XBee使用時に利用します。</p>
		 * 
		 * @param pinNum pin number
		 * @param mode normally accepts digital input, digital output, or PWM. However, analog input values can also be set.
		 */
		public function setDigitalPinMode(pinNum:uint, mode:uint):void {
			if (digitalPins == null) throw new ArgumentError("digital pins are not available");
			if (digitalPins[pinNum] == null) throw new ArgumentError("digital pin is not available at " + pinNum);
			if ([DIN, DOUT, AOUT].indexOf(mode) != -1) {
				config[digitalPins[pinNum]] = mode;
			} else if (AIN == mode) {
				if (analogPins == null) throw new ArgumentError("analog pins are not available");
				if (analogPins[pinNum] == null) throw new ArgumentError("analog pin is not available at " + pinNum);
				config[analogPins[pinNum]] = AIN;
			} else if (SERVO == mode) {
				if (servoPins == null) throw new ArgumentError("servo pins are not available");
				if (servoPins.indexOf(pinNum) == -1) throw new ArgumentError("servo pin is not available at " + pinNum);
				config[pinNum] = SERVO;
			} else {
				throw new ArgumentError("mode #" + mode +" is not available");
			}
		}

		/**
		 * Enables pins A2 and A3 on the arduino board to be used as GND and Power respectively
		 * as a convenience for some I2C devices (such as a BlinkM module).
		 * A2 will be set to GND and A3 will be set to VCC.
		 * 
		 * <p>WARNING: do not use this function unless you are sure you know what you are doing
		 * or you could damage your I2C device.</p>
		 */
		public function enablePowerPins():void {
			_powerPinsEnabled = true;
		}

		/**
		 * @return whether or not power pins are enabled
		 */
		public function get powerPinsEnabled():Boolean {
			return _powerPinsEnabled;
		}

		public function clone():Configuration {
			var clonedConfig:Configuration = new Configuration();

			if (this.ainPins != null)
				clonedConfig.ainPins = this.ainPins.concat();
			if (this.dinPins != null)
				clonedConfig.dinPins = this.dinPins.concat();
			if (this.aoutPins != null)
				clonedConfig.aoutPins = this.aoutPins.concat();
			if (this.doutPins != null)
				clonedConfig.doutPins = this.doutPins.concat();
			if (this.analogPins != null)
				clonedConfig.analogPins = this.analogPins.concat();
			if (this.digitalPins != null)
				clonedConfig.digitalPins = this.digitalPins.concat();
			if (this.servoPins != null)
				clonedConfig.servoPins = this.servoPins.concat();
			if (this.config != null)
				clonedConfig.config = this.config.concat();
			clonedConfig.button = this.button;
			clonedConfig.led = this.led;
			clonedConfig.moduleID = this.moduleID;
			clonedConfig._powerPinsEnabled = this._powerPinsEnabled;

			return clonedConfig;
		}
	}
}