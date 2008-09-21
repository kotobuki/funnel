package funnel
{
	/**
	 * I/Oモジュールのコンフィギュレーションを設定するためのクラスです。コンフィギュレーションはI/Oモジュールとの通信を開始する段階で決定する必要があるため、IOSystemのコンストラクタの引数で指定します。
	 * @see IOSystem#IOSystem()
	 */
	public class Configuration
	{
		/**
		* Gainer.analogInputを実際のポート番号に対応させるテーブル
		* @see Gainer#analogInput
		*/
		public var ainPorts:Array;

		/**
		* Gainer.digitalInputを実際のポート番号に対応させるテーブル
		* @see Gainer#digitalInput
		*/
		public var dinPorts:Array;

		/**
		* Gainer.analogOutputを実際のポート番号に対応させるテーブル
		* @see Gainer#analogOutput
		*/
		public var aoutPorts:Array;

		/**
		* Gainer.digitalOutputを実際のポート番号に対応させるテーブル
		* @see Gainer#digitalOutput
		*/
		public var doutPorts:Array;

		/**
		* Gainer.buttonを実際のポート番号に対応させるテーブル
		* @see Gainer#button
		*/
		public var button:uint;

		/**
		* Gainer.ledを実際のポート番号に対応させるテーブル
		* @see Gainer#led
		*/
		public var led:uint;

		/**
		* Arduino.analogPinを実際のポート番号に対応させるテーブル
		* @see Arduino#analogPin
		*/
		public var analogPins:Array;

		/**
		* Arduino.digitsalPinを実際のポート番号に対応させるテーブル
		* @see Arduino#digitsalPin
		*/
		public var digitalPins:Array;

		/**
		* ポートのタイプ(AIN、DIN、AOUT、DOUT)の配列
		* @see Port#AIN
		* @see Port#DIN
		* @see Port#AOUT
		* @see Port#DOUT
		*/
		public var config:Array;

		/**
		* モジュールのID
		*/
		public var moduleID:uint;

		/**
		 * デジタルピンのモードを設定します。Arduino、Fio、XBee使用時に利用します。
		 * @param portNum ピン番号
		 * @param mode 通常はデジタル入力(IN)、デジタル出力(OUT)、PWM(疑似アナログ出力)のいずれかを指定。ただし、アナログピンに対してアナログ入力(AIN)を設定することも可能。
		 */
		public function setDigitalPinMode(portNum:uint, mode:uint):void {
			if (digitalPins == null) throw new ArgumentError("digital pins are not available");
			if (digitalPins[portNum] == null) throw new ArgumentError("digital pin is not available at " + portNum);
			if ([DIN, DOUT, AOUT].indexOf(mode) != -1) {
				config[digitalPins[portNum]] = mode;
			} else if (AIN == mode) {
				if (analogPins == null) throw new ArgumentError("analog pins are not available");
				if (analogPins[portNum] == null) throw new ArgumentError("analog pin is not available at " + portNum);
				config[analogPins[portNum]] = mode;
			} else {
				throw new ArgumentError("mode #" + mode +" is not available");
			}
		}

	}
}