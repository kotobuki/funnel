package funnel
{
	/**
	 * I/Oモジュールのコンフィギュレーションを設定するためのクラスです。コンフィギュレーションはI/Oモジュールとの通信を開始する段階で決定する必要があるため、IOSystemのコンストラクタの引数で指定します。
	 * @see IOSystem#IOSystem()
	 */
	public class Configuration
	{
		/**
		* Gainer.analogInputを実際のピン番号に対応させるテーブル
		* @see Gainer#analogInput
		*/
		public var ainPins:Array;

		/**
		* Gainer.digitalInputを実際のピン番号に対応させるテーブル
		* @see Gainer#digitalInput
		*/
		public var dinPins:Array;

		/**
		* Gainer.analogOutputを実際のピン番号に対応させるテーブル
		* @see Gainer#analogOutput
		*/
		public var aoutPins:Array;

		/**
		* Gainer.digitalOutputを実際のピン番号に対応させるテーブル
		* @see Gainer#digitalOutput
		*/
		public var doutPins:Array;

		/**
		* Gainer.buttonを実際のピン番号に対応させるテーブル
		* @see Gainer#button
		*/
		public var button:uint;

		/**
		* Gainer.ledを実際のピン番号に対応させるテーブル
		* @see Gainer#led
		*/
		public var led:uint;

		/**
		* Arduino.analogPinを実際のピン番号に対応させるテーブル
		* @see Arduino#analogPin
		*/
		public var analogPins:Array;

		/**
		* Arduino.digitsalPinを実際のピン番号に対応させるテーブル
		* @see Arduino#digitsalPin
		*/
		public var digitalPins:Array;

		/**
		* ピンのタイプ(AIN、DIN、AOUT、DOUT)の配列
		* @see Pin#DIN
		* @see Pin#DOUT
		* @see Pin#AIN
		* @see Pin#AOUT
		* @see Pin#PWM
		* @see Pin#SERVO
		*/
		public var config:Array;

		/**
		* モジュールのID
		*/
		public var moduleID:uint;

		private var _powerPinsAreEnabled:Boolean = false;

		/**
		 * デジタルピンのモードを設定します。Arduino、Fio、XBee使用時に利用します。
		 * @param pinNum ピン番号
		 * @param mode 通常はデジタル入力(IN)、デジタル出力(OUT)、PWM(疑似アナログ出力)のいずれかを指定。ただし、アナログピンに対してアナログ入力(AIN)を設定することも可能。
		 */
		public function setDigitalPinMode(pinNum:uint, mode:uint):void {
			if (digitalPins == null) throw new ArgumentError("digital pins are not available");
			if (digitalPins[pinNum] == null) throw new ArgumentError("digital pin is not available at " + pinNum);
			if ([DIN, DOUT, AOUT].indexOf(mode) != -1) {
				config[digitalPins[pinNum]] = mode;
			} else if (AIN == mode) {
				if (analogPins == null) throw new ArgumentError("analog pins are not available");
				if (analogPins[pinNum] == null) throw new ArgumentError("analog pin is not available at " + pinNum);
				config[analogPins[pinNum]] = mode;
			} else {
				throw new ArgumentError("mode #" + mode +" is not available");
			}
		}

		public function enablePowerPins():void {
			_powerPinsAreEnabled = true;
		}

		public function get powerPinsAreEnabled():Boolean {
			return _powerPinsAreEnabled;
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
			if (this.config != null)
				clonedConfig.config = this.config.concat();
			clonedConfig.button = this.button;
			clonedConfig.led = this.led;
			clonedConfig.moduleID = this.moduleID;

			return clonedConfig;
		}
	}
}