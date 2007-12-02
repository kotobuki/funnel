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
		 * デジタルピンのモードを設定します。通常、Arduino使用時に利用します。
		 * @param portNum ピン番号
		 * @param mode デジタル入力(IN)、デジタル出力(OUT)、PWM(疑似アナログ出力)のいずれかを指定
		 */		
		public function setDigitalPinMode(portNum:uint, mode:uint):void {
			if (digitalPins == null) throw new ArgumentError("digital pins are not available");
			if (digitalPins[portNum] == null) throw new ArgumentError("digital pin is not available");
          	if ([DIN, DOUT, AOUT].indexOf(mode) != -1) {
          		config[digitalPins[portNum]] = mode;
          	} else {
          		throw new ArgumentError("mode #" + mode +" is not available");
          	}
        }
        
	}
}