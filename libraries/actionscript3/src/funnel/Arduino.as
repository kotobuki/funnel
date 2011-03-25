package funnel
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import funnel.gui.IOModuleGUI;
	
	/**
	 * A class for working with an Arduino board that is running either 
	 * StandardFirmata to act as an I/O module, or is otherwise using Firmata as 
	 * the communication protocol.
	 * 
	 * <p>ArduinoクラスはファームウェアとしてFirmataを搭載したArduinoをI/Oモジュールとして扱うためのクラスです</p>
	 */ 
	public class Arduino extends IOSystem
	{
		private var _pin:Function;
		private var _analogPins:Array;
		private var _digitalPins:Array;
		
		/**
		 * Gets the default Arduino configuration. Use setDigitalPinMode To set the pin IO configuration.
		 *
		 * <p>Arduino用のデフォルトのコンフィギュレーションを取得します。戻り値のコンフィギュレーションを変更するにはsetDigitalPinModeを利用します</p>
		 *
		 * @return Configuration object
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
			k.servoPins = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13];
			return k;
		}
		
		/**
		 * @param config Configuration of the Arduino such as Arduino.FIRMATA
		 * @param host IP address of the Funnel Server (default is "localhost")
		 * @param portNum port number of the Funnel Server (default is 9000)
		 * @param samplingInterval the sampling interval in milliseconds for inputs (default is 33)
		 */			
		public function Arduino(config:Configuration = null, host:String = "localhost", portNum:Number = 9000, samplingInterval:int = 33) {
			if (config == null) config = FIRMATA;
			super([config], host, portNum, samplingInterval);
			
			_pin = ioModule(0).pin;
			_analogPins = config.analogPins;
			_digitalPins = config.digitalPins;

			for (var i:int = 0; i < config.config.length; i++) {
				if (config.config[i] == SERVO) {
					setServoPulseRange(i, 544, 2400);
				}
			}

			if (config.powerPinsEnabled) {
				var timer:Timer = new Timer(I2C_POWER_PINS_STARTUP_TIME, 1);
				timer.addEventListener(TimerEvent.TIMER_COMPLETE, function(e:TimerEvent):void {
					dispatchEvent(new FunnelEvent(FunnelEvent.I2C_POWER_PINS_READY));
				});
				timer.start();
			}
		}
		
		/**
		 * @param pinNum pin number
		 * @return Pin a reference to the specified analog pin object
		 * @see Pin
		 */		
		public function analogPin(pinNum:uint):Pin {
			return _pin(_analogPins[pinNum]);
		}
		
		/**
		 * @param pinNum pin number
		 * @return Pin a reference to the specified digital pin object
		 * @see Pin
		 */
		public function digitalPin(pinNum:uint):Pin {
			return _pin(_digitalPins[pinNum]);
		}

		/**
		 * send a string to the Arduino
		 * @param String
		 */
		public function sendFirmataString(stringToSend:String):void {
			ioModule(0).sendFirmataString(stringToSend);
		}

		/**
		 * send a sysex message to the arduino see firmata.org for details
		 * @param command the message command
		 * @param message the message body as an Array
		 */
		public function sendSysexMessage(command:uint, message:Array):void {
			ioModule(0).sendSysex(command, message);
		}

		/**
		 * set the minimum and maximum servo pulse range for the servo attached to the
		 * specified pin number
		 * @param pinNumber the pin number of the attached servo
		 * @param minPulse the minimum pulse for the attached servo (see servo datasheet)
		 * @param maxPulse the maximum pulse for the attached servo (see servo datasheet)
		 */
		public function setServoPulseRange(pinNumber:uint, minPulse:uint, maxPulse:uint):void {
			ioModule(0).setServoPulseRange(pinNumber, minPulse, maxPulse);
		}

		public override function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
			if (type == FunnelEvent.FIRMATA_STRING) {
				ioModule(0).addEventListener(type, listener, useCapture, priority, useWeakReference);
			} else {
				super.addEventListener(type, listener, useCapture, priority, useWeakReference);
			}
		}

		public function get gui():IOModuleGUI {
			return ioModule(0).gui;
		}
		
		public function set gui(gui:IOModuleGUI):void {
			ioModule(0).gui = gui;;
		}
	}
}