package funnel
{
	import funnel.gui.IOModuleGUI;
	
	/**
	 * ArduinoクラスはファームウェアとしてFirmataを搭載したArduinoをI/Oモジュールとして扱うためのクラスです。
	 * 
	 */ 
	public class Arduino extends IOSystem
	{
		private var _pin:Function;
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
				DOUT, DOUT, DOUT, DOUT, DOUT, DOUT, DOUT,
				DOUT, DOUT, DOUT, DOUT, DOUT, DOUT, DOUT,
				AIN, AIN, AIN, AIN, AIN, AIN, AIN, AIN
			];
			k.analogPins = [14, 15, 16, 17, 18, 19, 20, 21];
			k.digitalPins = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21];
			return k;
		}
		
		/**
		 * @param config コンフィギュレーション。指定しない場合はArduino.FIRMATA
		 * @param host ホスト名
		 * @param portNum ポート番号
		 * @param samplingInterval サンプリング間隔(ms)
		 */			
		public function Arduino(config:Configuration = null, host:String = "localhost", portNum:Number = 9000, samplingInterval:int = 33) {
			if (config == null) config = FIRMATA;
			super([config], host, portNum, samplingInterval);
			
			_pin = ioModule(0).pin;
			_analogPins = config.analogPins;
			_digitalPins = config.digitalPins;
		}
		
		/**
		 * pinNumで指定したピンを取得します。
		 * @param pinNum ピン番号
		 * @return pinNumで指定したPinオブジェクト
		 * @see Pin
		 */		
		public function analogPin(pinNum:uint):Pin {
			return _pin(_analogPins[pinNum]);
		}
		
		/**
		 * pinNumで指定したピンを取得します。
		 * @param pinNum ピン番号
		 * @return pinNumで指定したPinオブジェクト
		 * @see Pin
		 */
		public function digitalPin(pinNum:uint):Pin {
			return _pin(_digitalPins[pinNum]);
		}

		public function sendFirmataString(stringToSend:String):void {
			ioModule(0).sendFirmataString(stringToSend);
		}

		public function sendSysexMessage(command:uint, message:Array):void {
			ioModule(0).sendSysex(command, message);
		}

		public function get gui():IOModuleGUI {
			return ioModule(0).gui;
		}
		
		public function set gui(gui:IOModuleGUI):void {
			ioModule(0).gui = gui;;
		}
	}
}