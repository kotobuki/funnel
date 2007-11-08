package funnel
{
	import funnel.shortcuts.AIN;
	import funnel.shortcuts.AOUT;
	import funnel.shortcuts.DIN;
	import funnel.shortcuts.DOUT;
	
	public class Configuration
	{
		public static function get GAINER_MODE1():Object {
			return {
				config:[
		    		AIN,  AIN,  AIN,  AIN,
		    		DIN,  DIN,  DIN,  DIN,
		    		AOUT, AOUT, AOUT, AOUT,
		    		DOUT, DOUT, DOUT, DOUT,
		    		DOUT, DIN
		    	],
		    	ainPorts:[0, 1, 2, 3],
          		dinPorts:[4, 5, 6, 7],
          		aoutPorts:[8, 9, 10, 11],
          		doutPorts:[12, 13, 14, 15],
          		button:17,
          		led:16
			}
		}
		
		public static function get GAINER_MODE2():Object {
			return {
				config:[
					AIN,  AIN,  AIN,  AIN,
					AIN,  AIN,  AIN,  AIN,
					AOUT, AOUT, AOUT, AOUT,
					DOUT, DOUT, DOUT, DOUT,
					DOUT, DIN
				],
		    	ainPorts:[0, 1, 2, 3, 4, 5, 6, 7],
          		aoutPorts:[8, 9, 10, 11],
          		doutPorts:[12, 13, 14, 15],
          		button:17,
          		led:16
			}
		}
		
		public static function get GAINER_MODE3():Object {
			return {
				config:[
					AIN,  AIN,  AIN,  AIN,
					DIN,  DIN,  DIN,  DIN,
					AOUT, AOUT, AOUT, AOUT,
					AOUT, AOUT, AOUT, AOUT,
					DOUT, DIN
				],
		    	ainPorts:[0, 1, 2, 3],
		    	dinPorts:[4, 5, 6, 7],
          		aoutPorts:[8, 9, 10, 11, 12, 13, 14, 15],
          		button:17,
          		led:16
			}
		}
		
		public static function get GAINER_MODE4():Object {
			return {
				config:[
					AIN,  AIN,  AIN,  AIN,
					AIN,  AIN,  AIN,  AIN,
					AOUT, AOUT, AOUT, AOUT,
					AOUT, AOUT, AOUT, AOUT,
					DOUT, DIN
				],
		    	ainPorts:[0, 1, 2, 3, 4, 5, 6, 7],
          		aoutPorts:[8, 9, 10, 11, 12, 13, 14, 15],
          		button:17,
          		led:16
			}
		}
		    
		public static function get GAINER_MODE5():Object {
			return {
				config:[
					DIN,  DIN,  DIN,  DIN,
					DIN,  DIN,  DIN,  DIN,
					DIN,  DIN,  DIN,  DIN,
					DIN,  DIN,  DIN,  DIN
		    	],
          		dinPorts:[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
			}
		}
		
		public static function get GAINER_MODE6():Object {
			return {
				config:[
					DOUT, DOUT, DOUT, DOUT,
					DOUT, DOUT, DOUT, DOUT,
					DOUT, DOUT, DOUT, DOUT,
					DOUT, DOUT, DOUT, DOUT
				],
          		doutPorts:[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
			}
		}
		
		public static function get GAINER_MODE7():Object {
			return {
				config:[
					AOUT, AOUT, AOUT, AOUT, AOUT, AOUT, AOUT, AOUT,
					AOUT, AOUT, AOUT, AOUT, AOUT, AOUT, AOUT, AOUT,
					AOUT, AOUT, AOUT, AOUT, AOUT, AOUT, AOUT, AOUT,
					AOUT, AOUT, AOUT, AOUT, AOUT, AOUT, AOUT, AOUT,
					AOUT, AOUT, AOUT, AOUT, AOUT, AOUT, AOUT, AOUT,
					AOUT, AOUT, AOUT, AOUT, AOUT, AOUT, AOUT, AOUT,
					AOUT, AOUT, AOUT, AOUT, AOUT, AOUT, AOUT, AOUT,
					AOUT, AOUT, AOUT, AOUT, AOUT, AOUT, AOUT, AOUT
				],
				aoutPorts:[
					0, 1, 2, 3, 4, 5, 6, 7,
					8, 9, 10, 11, 12, 13, 14, 15,
					16, 17, 18, 19, 20, 21, 22, 23,
					24, 25, 26, 27, 28, 29, 30, 31,
					32, 33, 34, 35, 36, 37, 38, 39,
					40, 41, 42, 43, 44, 45, 46, 47,
					48, 49, 50, 51, 52, 53, 54, 55,
					56, 57, 58, 59, 60, 61, 62, 63
				]
			}
		}
		
		public static function get GAINER_MODE8():Object {
			return {
				config:[
					DIN,  DIN,  DIN,  DIN,
					DIN,  DIN,  DIN,  DIN,
					DOUT, DOUT, DOUT, DOUT,
					DOUT, DOUT, DOUT, DOUT
				],
		    	dinPorts:[0, 1, 2, 3, 4, 5, 6, 7],
          		doutPorts:[8, 9, 10, 11, 12, 13, 14, 15]
			}
		}
		
		public static function get ARDUINO():Object {
			var config:Array = [
					AIN, AIN, AIN, AIN, AIN, AIN,
					DIN, DIN, DIN, DIN, DIN, DIN, DIN,
					DIN, DIN, DIN, DIN, DIN, DIN, DIN
			];
			var digitalPins:Array = [6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19];
			return {
				config:config,
		    	analogPins:[0, 1, 2, 3, 4, 5],
          		digitalPins:digitalPins,
          		setDigitalPinMode:function(portNum:uint, mode:uint):void {
          			if ([DIN, DOUT, AOUT].indexOf(mode) != -1) {
          				config[digitalPins[portNum]] = mode;
          			} else {
          				throw ArgumentError('mode #' + mode +' is not available');
          			}
          		}
			}
		}
	}
}