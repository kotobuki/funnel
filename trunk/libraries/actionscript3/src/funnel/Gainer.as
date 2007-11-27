package funnel
{
	/**
	 * Gainer I/Oモジュールを扱うためのクラスです。
	 */	
	public class Gainer extends IOSystem
	{
		private var _port:Function;
		private var _ainPorts:Array;
		private var _dinPorts:Array;
		private var _aoutPorts:Array;
		private var _doutPorts:Array;
		private var _button:uint;
		private var _led:uint;
		
		/**
		 * @param config コンフィギュレーション。指定しない場合はConfiguration.GAINER_MODE1
		 * @param host ホスト名
		 * @param portNum ポート番号
		 * @param samplingInterval サンプリング間隔(ms)
		 */
		public function Gainer(config:Configuration = null, host:String = "localhost", portNum:Number = 9000, samplingInterval:int = 33) {
			if (config == null) config = Configuration.GAINER_MODE1;
			super([config], host, portNum, samplingInterval);
			
			_port = module(0).port;
			_ainPorts = config.ainPorts;
			_dinPorts = config.dinPorts;
			_aoutPorts = config.aoutPorts;
			_doutPorts = config.doutPorts;
			_button = config.button;
			_led = config.led;
		}
		
		/**
		 * portNumで指定したポートを取得します。
		 * @param portNum ポート番号
		 * @return portNumで指定したPortオブジェクト
		 * @see Port
		 */	
		public function analogInput(portNum:uint):Port {
			return _port(_ainPorts[portNum]);
		}
		
		/**
		 * portNumで指定したポートを取得します。
		 * @param portNum ポート番号
		 * @return portNumで指定したPortオブジェクト
		 * @see Port
		 */	
		public function digitalInput(portNum:uint):Port {
			return _port(_dinPorts[portNum]);
		}
		
		/**
		 * portNumで指定したポートを取得します。
		 * @param portNum ポート番号
		 * @return portNumで指定したPortオブジェクト
		 * @see Port
		 */	
		public function analogOutput(portNum:uint):Port {
			return _port(_aoutPorts[portNum]);
		}
		
		/**
		 * portNumで指定したポートを取得します。
		 * @param portNum ポート番号
		 * @return portNumで指定したPortオブジェクト
		 * @see Port
		 */	
		public function digitalOutput(portNum:uint):Port {
			return _port(_doutPorts[portNum]);
		}
		
		/**
		 * I/Oモジュール上のボタンを表すポート
		 */	
		public function get button():Port {
			return _port(_button);
		}
		
		/**
		 * I/Oモジュール上のLEDを表すポート
		 */	
		public function get led():Port {
			return _port(_led);
		}
		
	}
}