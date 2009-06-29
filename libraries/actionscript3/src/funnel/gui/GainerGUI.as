package funnel.gui {

	import flash.events.Event;
	
	import funnel.*;

	public class GainerGUI extends IOModuleGUI {

		public function GainerGUI() {
			super();
		}

		override public function configure(id:int, config:Configuration):void {
			var i:int = 0;
			var pinNumber:int = 0;
			var offset:int = 0;

			_pin = new Array(config.config.length);

			if (config.ainPins != null) {
				for (i = 0; i < config.ainPins.length; i++) {
					pinNumber = config.ainPins[0] + i;
					_pin[pinNumber] = new OnScreenController("ain " + i, 128, OnScreenController.ANALOG);
					_pin[pinNumber].y = offset;
					_pin[pinNumber].value = 0;
					_pin[pinNumber].addEventListener(Event.CHANGE, onInputChange);
					addChild(_pin[pinNumber]);
					offset += 16;
				}
			}

			if (config.dinPins != null) {
				for (i = 0; i < config.dinPins.length; i++) {
					pinNumber = config.dinPins[0] + i;
					_pin[pinNumber] = new OnScreenController("din " + i, 58, OnScreenController.DIGITAL_TOGGLE);
					_pin[pinNumber].y = offset;
					_pin[pinNumber].value = 0;
					_pin[pinNumber].addEventListener(Event.CHANGE, onInputChange);
					addChild(_pin[pinNumber]);
					offset += 16;
				}
			}

			if (!isNaN(config.led)) {
				offset += 4;
				pinNumber = config.led;
				_pin[pinNumber] = new OnScreenController("LED", 58, OnScreenController.DIGITAL_MOMENTARY, false);
				_pin[pinNumber].y = offset;
				_pin[pinNumber].value = 0;
				addChild(_pin[pinNumber]);
			}

			offset = 0;
			if (config.aoutPins != null) {
				for (i = 0; i < config.aoutPins.length; i++) {
					pinNumber = config.aoutPins[0] + i;
					_pin[pinNumber] = new OnScreenController("aout " + i, 128, OnScreenController.ANALOG, false);
					_pin[pinNumber].x = 128 + 16;
					_pin[pinNumber].y = offset;
					_pin[pinNumber].value = 0;
					addChild(_pin[pinNumber]);
					offset += 16;
				}
			}

			if (config.doutPins != null) {
				for (i = 0; i < config.doutPins.length; i++) {
					pinNumber = config.doutPins[0] + i;
					_pin[pinNumber] = new OnScreenController("dout " + i, 58, OnScreenController.DIGITAL_TOGGLE, false);
					_pin[pinNumber].x = 128 + 16;
					_pin[pinNumber].y = offset;
					_pin[pinNumber].value = 0;
					addChild(_pin[pinNumber]);
					offset += 16;
				}
			}

			if (!isNaN(config.button)) {
				offset += 4;
				pinNumber = config.button;
				_pin[pinNumber] = new OnScreenController("Button", 58, OnScreenController.DIGITAL_MOMENTARY);
				_pin[pinNumber].x = 128 + 16;
				_pin[pinNumber].y = offset;
				_pin[pinNumber].value = 0;
				_pin[pinNumber].addEventListener(Event.CHANGE, onInputChange);
				addChild(_pin[pinNumber]);
			}
		}

	}
}