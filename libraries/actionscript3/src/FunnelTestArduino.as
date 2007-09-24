package {
	import flash.display.*;	
	import flash.events.*;
	import flash.text.*;
	import funnel.*;
	import funnel.filter.*;
	import funnel.ioport.*;
	import funnel.event.*;

	public class FunnelTestArduino extends Sprite
	{
		include "alias.as"
		
		private var fio:Funnel;
		
		public function FunnelTestArduino()
		{	
			var ANALOG_0:uint	= 0;
			var DIGITAL_2:uint	= 8;	//e.g. DIGITAL_0 = 6
			var DIGITAL_11:uint	= 17;	//e.g. DIGITAL_0 = 6
			var DIGITAL_12:uint	= 18;	//e.g. DIGITAL_0 = 6

			/*
			 * Preparation
			 * 1. Connect a sensor (e.g. a potentiometer) to Analog In 0
			 * 2. Connect a LED to Digital 11
			 * 3. Connect a switch to Digital 2 (should be pulled down)
			 */

			var config:Array = [AIN, AIN, AIN, AIN, AIN, AIN, DIN, DIN, DIN, AOUT, DOUT, AOUT, AOUT, DOUT, DOUT, AOUT, AOUT, AOUT, DOUT, DOUT];

			fio = new Funnel(config);

			/*
			//An example of how to handle events
			fio.addEventListener(READY, function(event:Event):void {
				trace("onReady");
			});
			fio.addEventListener(SERVER_NOT_FOUND_ERROR, function(event:ErrorEvent):void {
				trace("ERROR: Server not found");
				//trace(event.text); //print details of the error event
			});
			*/
			
			//Set a sin oscillator on Digital 11 to drive a LED
			fio.port(DIGITAL_11).filters = [new Osc(Osc.SIN, 1, 2, -1, 0, 1)];	//wave, frequency, amplitude, offset, phase, times
			//If the switch is pressed, (re)start the oscillator
			fio.port(DIGITAL_2).addEventListener(RISING_EDGE, function(e:Event):void {
				fio.port(DIGITAL_11).filters[0].reset();
				fio.port(DIGITAL_11).filters[0].start();
			});
			
			//Set a SetPoint filter to the Analog In 0, then trace changes
			fio.port(ANALOG_0).filters = [ new SetPoint([[0.5, 0.05], [0.7, 0.05]]) ];
			var stateTransitionMatrix:Array = [
				["0 -> 0", "0 -> 1", "0 -> 2"],
				["1 -> 0", "1 -> 1", "1 -> 2"],
				["2 -> 0", "2 -> 1", "2 -> 2"]
			];
			fio.port(ANALOG_0).addEventListener(CHANGE, function(e:PortEvent):void {
				//An example of how to access values (last and currrent)
				trace(stateTransitionMatrix[e.target.lastValue][e.target.value]);
			});

			createView();
		}
		
		private function createView():void {
			//Create text fields to show input values
			var tf:TextField = new TextField();
			tf.autoSize = TextFieldAutoSize.LEFT;
			addChild(tf);

			addEventListener(Event.ENTER_FRAME, function(event:Event):void {
				var inputInfo:String = "";
				for (var i:uint = 0; i < fio.portCount; ++i) {
					var aPort:Port = fio.port(i);
					var type:uint = aPort.type;
					if (type == AIN || type == DIN) {
						var pad:String = i < 10 ? "0" : "";
						inputInfo += "port[" + pad + i + "]: ";
						inputInfo += format(aPort.value, 3);
						inputInfo += "    ave: " + format(aPort.average, 3);
						inputInfo += "    min: " + format(aPort.minimum, 3);
						inputInfo += "    max: " + format(aPort.maximum, 3);
						inputInfo += "\n";
					}
				}
				tf.text = inputInfo;
			});
		}
		
		private static function format(num:Number, digits:Number):String {
 			if (digits <= 0) {
				return Math.round(num).toString();
			} 
			var tenToPower:Number = Math.pow(10, digits);
			var cropped:String = String(Math.round(num * tenToPower) / tenToPower);
			if (cropped.indexOf(".") == -1) {
				cropped += ".0";
			}

			var halves:Array = cropped.split(".");
			var zerosNeeded:Number = digits - halves[1].length;
			for (var i:uint = 1; i <= zerosNeeded; i++) {
				cropped += "0";
			}
			return(cropped);
		}
	}
}
