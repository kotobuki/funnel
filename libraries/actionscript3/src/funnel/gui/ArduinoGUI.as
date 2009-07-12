package funnel.gui {

	import flash.display.Shape;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import funnel.*;

	public class ArduinoGUI extends IOModuleGUI {

		private var _messageAreaBase:Shape;

		public function ArduinoGUI() {
			super();
		}

		public override function configure(id:int, config:Configuration):void {
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
					case Pin.SERVO:
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
				offset += OnScreenController.HEIGHT + 1;
			}

			_messageAreaBase = new Shape();
			_messageAreaBase.graphics.beginFill(0x404040);
			_messageAreaBase.graphics.drawRoundRect(0, 0, this.width, OnScreenController.HEIGHT, 4, 4);
			_messageAreaBase.graphics.endFill();
			_messageAreaBase.y = offset;
			addChild(_messageAreaBase);

			_messageArea = new TextField;
			_messageArea.height = _messageAreaBase.height;
			_messageArea.x = _messageAreaBase.x + 1;
			_messageArea.y = _messageAreaBase.y - 0.5;
			_messageArea.autoSize = TextFieldAutoSize.NONE;
			_messageArea.defaultTextFormat = new TextFormat('Verdana', 8, 0xE0E0E0, null, null, null, null, null, TextFormatAlign.LEFT);
			_messageArea.text = "Arduino (via Firmata)";
			addChild(_messageArea);

			var base:Shape = new Shape();
			base.graphics.beginFill(0x044F6F, 0.7);
			base.graphics.drawRoundRect(0, 0, this.width, this.height, 4, 4);
			base.graphics.endFill();
			this.addChildAt(base, 0);

			// set initial position to right-bottom
			this.setPosition(IOModuleGUI.RIGHT_BOTTOM);
		}

	}
}