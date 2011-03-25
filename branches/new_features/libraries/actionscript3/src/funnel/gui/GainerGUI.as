package funnel.gui {

	import flash.display.Shape;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	import funnel.*;

	public class GainerGUI extends IOModuleGUI {

		private var _messageAreaBase:Shape;

		public function GainerGUI() {
			super();
		}

		public override function configure(id:int, config:Configuration):void {
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
					offset += OnScreenController.HEIGHT + 1;
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
					offset += OnScreenController.HEIGHT + 1;
				}
			}

			if (!isNaN(config.led)) {
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
					_pin[pinNumber].x = 128 + 1;
					_pin[pinNumber].y = offset;
					_pin[pinNumber].value = 0;
					addChild(_pin[pinNumber]);
					offset += OnScreenController.HEIGHT + 1;
				}
			}

			if (config.doutPins != null) {
				for (i = 0; i < config.doutPins.length; i++) {
					pinNumber = config.doutPins[0] + i;
					_pin[pinNumber] = new OnScreenController("dout " + i, 58, OnScreenController.DIGITAL_TOGGLE, false);
					_pin[pinNumber].x = 128 + 1;
					_pin[pinNumber].y = offset;
					_pin[pinNumber].value = 0;
					addChild(_pin[pinNumber]);
					offset += OnScreenController.HEIGHT + 1;
				}
			}

			if (!isNaN(config.button)) {
				pinNumber = config.button;
				_pin[pinNumber] = new OnScreenController("Button", 58, OnScreenController.DIGITAL_MOMENTARY);
				_pin[pinNumber].x = 128 + 1;
				_pin[pinNumber].y = offset;
				_pin[pinNumber].value = 0;
				_pin[pinNumber].addEventListener(Event.CHANGE, onInputChange);
				addChild(_pin[pinNumber]);
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
			_messageArea.text = "Gainer I/O";
			addChild(_messageArea);

			var base:Shape = new Shape();
			base.graphics.beginFill(0xFF0000, 0.7);
			base.graphics.drawRoundRect(0, 0, this.width, this.height, 4, 4);
			base.graphics.endFill();
			this.addChildAt(base, 0);

			// set initial position to right-bottom
			this.setPosition(IOModuleGUI.RIGHT_BOTTOM);
		}

	}
}