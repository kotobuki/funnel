package funnel.gui {

	import flash.events.Event;
	import funnel.*;

	public class ArduinoGUI extends IOModuleGUI {

		public function ArduinoGUI() {
			super();
		}

		override public function configure(id:int, config:Configuration):void {
			var offset:int = 0;

			var type:int = OnScreenController.ANALOG;
			var isInput:Boolean = true;
			var controllerWidth:int = 128;

			_pin = new Array(config.digitalPins.length);
			for (var i:int = 0; i < _pin.length; i++) {
				switch (config.config[i]) {
					case Pin.AIN:
						type = OnScreenController.ANALOG;
						isInput = true;
						controllerWidth = 128;
						break;
					case Pin.DIN:
						type = OnScreenController.DIGITAL_TOGGLE;
						isInput = true;
						controllerWidth = 58;
						break;
					case Pin.DOUT:
						type = OnScreenController.DIGITAL_TOGGLE;
						isInput = false;
						controllerWidth = 58;
						break;
					case Pin.PWM:
						type = OnScreenController.ANALOG;
						isInput = false;
						controllerWidth = 128;
						break
				}

				var pinName:String = (config.config[i] == Pin.AIN) ? "D" + i + "/A" + (i - config.analogPins[0]) : "D" + i;
				_pin[i] = new OnScreenController(pinName, controllerWidth, type, isInput);
				_pin[i].x = 0;
				_pin[i].y = offset;
				_pin[i].value = 0;
				_pin[i].addEventListener(Event.CHANGE, onInputChange);
				addChild(_pin[i]);
				offset += 16;
			}
		}

	}
}