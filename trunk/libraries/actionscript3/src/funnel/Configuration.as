package funnel
{
	public class Configuration
	{	
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
		
		public var ainPorts:Array;
		public var dinPorts:Array;
		public var aoutPorts:Array;
		public var doutPorts:Array;
		public var analogPins:Array;
		public var digitalPins:Array;
		public var button:uint;
		public var led:uint;
		public var config:Array;
		
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