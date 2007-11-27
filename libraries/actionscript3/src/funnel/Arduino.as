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
		 * @param configs Configurationオブジェクト
		 * @param host ホスト名
		 * @param portNum ポート番号
		 * @param samplingInterval サンプリング間隔(ms)
		 */			
		public function Arduino(config:Configuration = null, host:String = "localhost", portNum:Number = 9000, samplingInterval:int = 33) {
			if (config == null) config = Configuration.ARDUINO;
			super([config], host, portNum, samplingInterval);
			
			_port = module(0).port;
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