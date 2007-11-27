package funnel
{
	/**
	 * I/Oモジュールのコンフィギュレーションを設定するためのクラスです。コンフィギュレーションはI/Oモジュールとの通信を開始する段階で決定する必要があるため、IOSystemのコンストラクタの引数で指定します。
	 * @see IOSystem#IOSystem()
	 */	
	public class Configuration
	{	
		/**
		 * GAINERに用意されている8種類のコンフィギュレーションのうちの一つです。通常、Gainerのコンストラクタの引数で指定します。
		 * @return Configurationオブジェクト
		 * @see http://gainer.cc/Cookbook/ChangeConfiguration?p=2
		 * @see Gainer#Gainer()
		 */
		public static function get GAINER_MODE1():Configuration {
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
		 * GAINERに用意されている8種類のコンフィギュレーションのうちの一つです。通常、Gainerのコンストラクタの引数で指定します。
		 * @return Configurationオブジェクト
		 * @see http://gainer.cc/Cookbook/ChangeConfiguration?p=2
		 * @see Gainer#Gainer()
		 */
		public static function get GAINER_MODE2():Configuration {
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
		 * GAINERに用意されている8種類のコンフィギュレーションのうちの一つです。通常、Gainerのコンストラクタの引数で指定します。
		 * @return Configurationオブジェクト
		 * @see http://gainer.cc/Cookbook/ChangeConfiguration?p=2
		 * @see Gainer#Gainer()
		 */
		public static function get GAINER_MODE3():Configuration {
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
		 * GAINERに用意されている8種類のコンフィギュレーションのうちの一つです。通常、Gainerのコンストラクタの引数で指定します。
		 * @return Configurationオブジェクト
		 * @see http://gainer.cc/Cookbook/ChangeConfiguration?p=2
		 * @see Gainer#Gainer()
		 */
		public static function get GAINER_MODE4():Configuration {
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
		 * GAINERに用意されている8種類のコンフィギュレーションのうちの一つです。通常、Gainerのコンストラクタの引数で指定します。
		 * @return Configurationオブジェクト
		 * @see http://gainer.cc/Cookbook/ChangeConfiguration?p=2
		 * @see Gainer#Gainer()
		 */
		public static function get GAINER_MODE5():Configuration {
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
		 * GAINERに用意されている8種類のコンフィギュレーションのうちの一つです。通常、Gainerのコンストラクタの引数で指定します。
		 * @return Configurationオブジェクト
		 * @see http://gainer.cc/Cookbook/ChangeConfiguration?p=2
		 * @see Gainer#Gainer()
		 */
		public static function get GAINER_MODE6():Configuration {
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
		 * GAINERに用意されている8種類のコンフィギュレーションのうちの一つです。通常、Gainerのコンストラクタの引数で指定します。
		 * @return Configurationオブジェクト
		 * @see http://gainer.cc/Cookbook/ChangeConfiguration?p=2
		 * @see Gainer#Gainer()
		 */
		public static function get GAINER_MODE7():Configuration {
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
		 * GAINERに用意されている8種類のコンフィギュレーションのうちの一つです。通常、Gainerのコンストラクタの引数で指定します。
		 * @return Configurationオブジェクト
		 * @see http://gainer.cc/Cookbook/ChangeConfiguration?p=2
		 * @see Gainer#Gainer()
		 */	
		public static function get GAINER_MODE8():Configuration {
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
		 * Arduino用のコンフィギュレーションの雛形を取得します。戻り値のコンフィギュレーションを変更するにはsetDigitalPinModeを利用します。
		 * @return Configurationオブジェクト
		 * @see Arduino#Arduino()
		 * @see Configuration#setDigitalPinMode()
		 */		
		public static function get ARDUINO():Configuration {
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