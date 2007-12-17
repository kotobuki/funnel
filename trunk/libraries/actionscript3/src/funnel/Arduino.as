package funnel
{
	/**
	 * ArduinoクラスはファームウェアとしてFirmataを搭載したArduinoをI/Oモジュールとして扱うためのクラスです。
	 * 
	 */	
	public class Arduino extends IOSystem
	{
		private var _port:Function;
		private var _analogPins:Array;
		private var _digitalPins:Array;
		
		/**
		 * Arduino用のデフォルトのコンフィギュレーションを取得します。戻り値のコンフィギュレーションを変更するにはsetDigitalPinModeを利用します。
		 * @return Configurationオブジェクト
		 * @see Arduino#Arduino()
		 * @see Configuration#setDigitalPinMode()
		 */		
		public static function get FIRMATA():Configuration {
			var k:Configuration = new Configuration();
			k.config = [
				AIN, AIN, AIN, AIN, AIN, AIN,
				DIN, DIN, DIN, DIN, DIN, DIN, DIN,
				DIN, DIN, DIN, DIN, DIN, DIN, DIN
			];
			k.analogPins = [0, 1, 2, 3, 4, 5];
			k.digitalPins = [6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19];
			return k;
		}
		
		/**
		 * @param configs コンフィギュレーション。指定しない場合はArduino.FIRMATA
		 * @param host ホスト名
		 * @param portNum ポート番号
		 * @param samplingInterval サンプリング間隔(ms)
		 */			
		public function Arduino(config:Configuration = null, host:String = "localhost", portNum:Number = 9000, samplingInterval:int = 33) {
			if (config == null) config = FIRMATA;
			super([config], host, portNum, samplingInterval);
			
			_port = ioModule(0).port;
			_analogPins = config.analogPins;
			_digitalPins = config.digitalPins;
		}
		
		/**
		 * pinNumで指定したポートを取得します。
		 * @param pinNum ポート番号
		 * @return pinNumで指定したPortオブジェクト
		 * @see Port
		 */		
		public function analogPin(pinNum:uint):Port {
			return _port(_analogPins[pinNum]);
		}
		
		/**
		 * pinNumで指定したポートを取得します。
		 * @param pinNum ポート番号
		 * @return pinNumで指定したPortオブジェクト
		 * @see Port
		 */
		public function digitalPin(pinNum:uint):Port {
			return _port(_digitalPins[pinNum]);
		}
		
	}
}