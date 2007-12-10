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
		 * GAINERに用意されている8種類のコンフィギュレーションのうちの一つです。通常、Gainerのコンストラクタの引数で指定します。
		 * @return Configurationオブジェクト
		 * @see http://gainer.cc/Cookbook/ChangeConfiguration?p=2
		 * @see Gainer#Gainer()
		 */
		public static function get MODE1():Configuration {
			var k:Configuration = new Configuration();
			k.config = [
		    	AIN,  AIN,  AIN,  AIN,
		    	DIN,  DIN,  DIN,  DIN,
		    	AOUT, AOUT, AOUT, AOUT,
		    	DOUT, DOUT, DOUT, DOUT,
		    	DOUT, DIN
		    ];
		    k.ainPorts = [0, 1, 2, 3];
		    k.dinPorts = [4, 5, 6, 7];
		    k.aoutPorts = [8, 9, 10, 11];
		    k.doutPorts = [12, 13, 14, 15];
		    k.button = 17;
		    k.led = 16;
		    return k;
		}
		
		/**
		 * @copy Gainer#MODE1()
		 */	
		public static function get MODE2():Configuration {
			var k:Configuration = new Configuration();
			k.config = [
				AIN,  AIN,  AIN,  AIN,
				AIN,  AIN,  AIN,  AIN,
				AOUT, AOUT, AOUT, AOUT,
				DOUT, DOUT, DOUT, DOUT,
				DOUT, DIN
			];
		    k.ainPorts = [0, 1, 2, 3, 4, 5, 6, 7];
		    k.aoutPorts = [8, 9, 10, 11];
		    k.doutPorts = [12, 13, 14, 15];
		    k.button = 17;
		    k.led = 16;
		    return k;
		}
		
		/**
		 * @copy Gainer#MODE1()
		 */	
		public static function get MODE3():Configuration {
			var k:Configuration = new Configuration();
			k.config = [
				AIN,  AIN,  AIN,  AIN,
				DIN,  DIN,  DIN,  DIN,
				AOUT, AOUT, AOUT, AOUT,
				AOUT, AOUT, AOUT, AOUT,
				DOUT, DIN
			];
		    k.ainPorts = [0, 1, 2, 3];
		    k.dinPorts = [4, 5, 6, 7];
		    k.aoutPorts = [8, 9, 10, 11, 12, 13, 14, 15];
		    k.button = 17;
		    k.led = 16;
		    return k;
		}
		
		/**
		 * @copy Gainer#MODE1()
		 */	
		public static function get MODE4():Configuration {
			var k:Configuration = new Configuration();
			k.config = [
				AIN,  AIN,  AIN,  AIN,
				AIN,  AIN,  AIN,  AIN,
				AOUT, AOUT, AOUT, AOUT,
				AOUT, AOUT, AOUT, AOUT,
				DOUT, DIN
			];
		    k.ainPorts = [0, 1, 2, 3, 4, 5, 6, 7];
          	k.aoutPorts = [8, 9, 10, 11, 12, 13, 14, 15];
          	k.button = 17;
          	k.led = 16;
          	return k;
		}
		
		/**
		 * @copy Gainer#MODE1()
		 */	
		public static function get MODE5():Configuration {
			var k:Configuration = new Configuration();
			k.config = [
				DIN,  DIN,  DIN,  DIN,
				DIN,  DIN,  DIN,  DIN,
				DIN,  DIN,  DIN,  DIN,
				DIN,  DIN,  DIN,  DIN
		    ];
          	k.dinPorts = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];
			return k;
		}
		
		/**
		 * @copy Gainer#MODE1()
		 */	
		public static function get MODE6():Configuration {
			var k:Configuration = new Configuration();
			k.config = [
				DOUT, DOUT, DOUT, DOUT,
				DOUT, DOUT, DOUT, DOUT,
				DOUT, DOUT, DOUT, DOUT,
				DOUT, DOUT, DOUT, DOUT
			];
          	k.doutPorts = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];
			return k;
		}
		
		/**
		 * @copy Gainer#MODE1()
		 */	
		public static function get MODE7():Configuration {
			var k:Configuration = new Configuration();
			k.config = [
				AOUT, AOUT, AOUT, AOUT, AOUT, AOUT, AOUT, AOUT,
				AOUT, AOUT, AOUT, AOUT, AOUT, AOUT, AOUT, AOUT,
				AOUT, AOUT, AOUT, AOUT, AOUT, AOUT, AOUT, AOUT,
				AOUT, AOUT, AOUT, AOUT, AOUT, AOUT, AOUT, AOUT,
				AOUT, AOUT, AOUT, AOUT, AOUT, AOUT, AOUT, AOUT,
				AOUT, AOUT, AOUT, AOUT, AOUT, AOUT, AOUT, AOUT,
				AOUT, AOUT, AOUT, AOUT, AOUT, AOUT, AOUT, AOUT,
				AOUT, AOUT, AOUT, AOUT, AOUT, AOUT, AOUT, AOUT
			];
			k.aoutPorts = [
				0, 1, 2, 3, 4, 5, 6, 7,
				8, 9, 10, 11, 12, 13, 14, 15,
				16, 17, 18, 19, 20, 21, 22, 23,
				24, 25, 26, 27, 28, 29, 30, 31,
				32, 33, 34, 35, 36, 37, 38, 39,
				40, 41, 42, 43, 44, 45, 46, 47,
				48, 49, 50, 51, 52, 53, 54, 55,
				56, 57, 58, 59, 60, 61, 62, 63
			];
			return k;
		}
		
		/**
		 * @copy Gainer#MODE1()
		 */	
		public static function get MODE8():Configuration {
			var k:Configuration = new Configuration();
			k.config = [
				DIN,  DIN,  DIN,  DIN,
				DIN,  DIN,  DIN,  DIN,
				DOUT, DOUT, DOUT, DOUT,
				DOUT, DOUT, DOUT, DOUT
			];
		    k.dinPorts = [0, 1, 2, 3, 4, 5, 6, 7];
          	k.doutPorts = [8, 9, 10, 11, 12, 13, 14, 15];
			return k;
		}
		
		/**
		 * @param config コンフィギュレーション。指定しない場合はGainer.MODE1
		 * @param host ホスト名
		 * @param portNum ポート番号
		 * @param samplingInterval サンプリング間隔(ms)
		 */
		public function Gainer(config:Configuration = null, host:String = "localhost", portNum:Number = 9000, samplingInterval:int = 33) {
			if (config == null) config = MODE1;
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