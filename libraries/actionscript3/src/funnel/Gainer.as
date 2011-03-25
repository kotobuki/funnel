package funnel
{
	import funnel.gui.IOModuleGUI;
	import funnel.ui.*;
	
	/**
	 * Gainer I/O module.
	 * 
	 * <p>Gainer I/Oモジュールを扱うためのクラスです。</p>
	 */ 
	public class Gainer extends IOSystem
	{
		private var _pin:Function;
		private var _ainPins:Array;
		private var _dinPins:Array;
		private var _aoutPins:Array;
		private var _doutPins:Array;
		private var _button:Button;
		private var _led:LED;
		
		/**
		 * Eight different configurations are available. The mode is set as the first argument
		 * to the Gainer constructor.
		 * 
		 * GAINERに用意されている8種類のコンフィギュレーションのうちの一つです。通常、Gainerのコンストラクタの引数で指定します。
		 * @return Configuration object
		 * @see http://gainer.cc/Cookbook/ChangeConfiguration?p=2
		 * @see Gainer#Gainer()
		 */
		public static function get MODE1():Configuration {
			var k:Configuration = new Configuration();
			k.config = [
				AIN,  AIN,	AIN,  AIN,
				DIN,  DIN,	DIN,  DIN,
				AOUT, AOUT, AOUT, AOUT,
				DOUT, DOUT, DOUT, DOUT,
				DOUT, DIN
			];
			k.ainPins = [0, 1, 2, 3];
			k.dinPins = [4, 5, 6, 7];
			k.aoutPins = [8, 9, 10, 11];
			k.doutPins = [12, 13, 14, 15];
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
				AIN,  AIN,	AIN,  AIN,
				AIN,  AIN,	AIN,  AIN,
				AOUT, AOUT, AOUT, AOUT,
				DOUT, DOUT, DOUT, DOUT,
				DOUT, DIN
			];
			k.ainPins = [0, 1, 2, 3, 4, 5, 6, 7];
			k.aoutPins = [8, 9, 10, 11];
			k.doutPins = [12, 13, 14, 15];
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
				AIN,  AIN,	AIN,  AIN,
				DIN,  DIN,	DIN,  DIN,
				AOUT, AOUT, AOUT, AOUT,
				AOUT, AOUT, AOUT, AOUT,
				DOUT, DIN
			];
			k.ainPins = [0, 1, 2, 3];
			k.dinPins = [4, 5, 6, 7];
			k.aoutPins = [8, 9, 10, 11, 12, 13, 14, 15];
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
				AIN,  AIN,	AIN,  AIN,
				AIN,  AIN,	AIN,  AIN,
				AOUT, AOUT, AOUT, AOUT,
				AOUT, AOUT, AOUT, AOUT,
				DOUT, DIN
			];
			k.ainPins = [0, 1, 2, 3, 4, 5, 6, 7];
			k.aoutPins = [8, 9, 10, 11, 12, 13, 14, 15];
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
				DIN,  DIN,	DIN,  DIN,
				DIN,  DIN,	DIN,  DIN,
				DIN,  DIN,	DIN,  DIN,
				DIN,  DIN,	DIN,  DIN
			];
			k.dinPins = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];
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
			k.doutPins = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];
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
			k.aoutPins = [
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
				DIN,  DIN,	DIN,  DIN,
				DIN,  DIN,	DIN,  DIN,
				DOUT, DOUT, DOUT, DOUT,
				DOUT, DOUT, DOUT, DOUT
			];
			k.dinPins = [0, 1, 2, 3, 4, 5, 6, 7];
			k.doutPins = [8, 9, 10, 11, 12, 13, 14, 15];
			return k;
		}
		
		/**
		 * @param config Configuration such as Gainer.MODE1
		 * @param host IP address of the Funnel Server (default is "localhost")
		 * @param portNum port number of the Funnel Server (default is 9000)
		 * @param samplingInterval the sampling interval in milliseconds for inputs (default is 33)
		 */
		public function Gainer(config:Configuration = null, host:String = "localhost", portNum:Number = 9000, samplingInterval:int = 33) {
			if (config == null) config = MODE1;
			super([config], host, portNum, samplingInterval);
			
			_pin = ioModule(config.moduleID).pin;
			_ainPins = config.ainPins;
			_dinPins = config.dinPins;
			_aoutPins = config.aoutPins;
			_doutPins = config.doutPins;

			if (config.button != 0) {
				_button = new Button(_pin(config.button));
			}
			if (config.led != 0) {
				_led = new LED(_pin(config.led));
			}
		}
		
		/**
		 * @param pinNum pin number
		 * @return Pin a reference to the specified analog pin object
		 * @see Pin
		 */	
		public function analogInput(pinNum:uint):Pin {
			return _pin(_ainPins[pinNum]);
		}
		
		/**
		 * @param pinNum pin number
		 * @return Pin a reference to the specified digital pin object
		 * @see Pin
		 */
		public function digitalInput(pinNum:uint):Pin {
			return _pin(_dinPins[pinNum]);
		}
		
		/**
		 * @param pinNum pin number
		 * @return Pin a reference to the specified analog output pin object
		 * @see Pin
		 */ 
		public function analogOutput(pinNum:uint):Pin {
			return _pin(_aoutPins[pinNum]);
		}
		
		/**
		 * @param pinNum pin number
		 * @return Pin a reference to the specified digital output pin object
		 * @see Pin
		 */ 
		public function digitalOutput(pinNum:uint):Pin {
			return _pin(_doutPins[pinNum]);
		}
		
		/**
		 * @see funnel.ui.Button
		 */ 
		public function get button():Button {
			return _button;
		}
		
		/**
		 * @see funnel.ui.LED
		 */ 
		public function get led():LED {
			return _led;
		}

		public function get gui():IOModuleGUI {
			return ioModule(0).gui;
		}
		
		public function set gui(gui:IOModuleGUI):void {
			ioModule(0).gui = gui;
		}
	}
}