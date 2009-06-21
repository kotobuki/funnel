package funnel.gui {

	import flash.display.Sprite;
	import flash.events.Event;
	import funnel.Configuration;
	import funnel.Pin;
	import funnel.Task;
	import funnel.osc.*;

	public class ArduinoGUI extends Sprite implements IOnScreenCommandPort {

		private static const MODULE_ID:int = 0;

		private var _digitalPin:Array;

		private var _inputMessage:OSCMessage;

		private var _task:Task;

		public function ArduinoGUI(config:Configuration) {
			super();

			var offset:int = 0;

			var type:int = OnScreenController.ANALOG;
			var isInput:Boolean = true;
			var controllerWidth:int = 128;

			_digitalPin = new Array(config.digitalPins.length);
			for (var i:int = 0; i < _digitalPin.length; i++) {
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
				_digitalPin[i] = new OnScreenController(pinName, controllerWidth, type, isInput);
				_digitalPin[i].x = 0;
				_digitalPin[i].y = offset;
				_digitalPin[i].value = 0;
				_digitalPin[i].addEventListener(Event.CHANGE, onInputChange);
				addChild(_digitalPin[i]);
				offset += 16;
			}
		}

		public function connect(host:String, port:Number):Task {
			var task:Task = Task.waitEvent(this, Event.CONNECT);
			dispatchEvent(new Event(Event.CONNECT));

			return task;
		}

		public function get inputMessage():OSCMessage {
			return _inputMessage;
		}

		public function writeCommand(command:OSCMessage):Task {
			_task = new Task();
			var pinValues:Array = command.value;
			if (command.address == "/out" && pinValues[0].value == 0) {
				var startPinNum:uint = pinValues[1].value;
				for (var j:int = 0; j < pinValues.length - 2; ++j) {
					var value:Number = pinValues[j + 2].value;
					var pinNumber:int = startPinNum + j;
					_digitalPin[pinNumber].value = value;
					_task.complete();
				}
			} else if (command.address == "/reset") {
				_task.complete();
			} else if (command.address == "/configure") {
				// TODO: handle configuration message, raise an argument error if needed
				_task.complete();
			} else if (command.address == "/samplingInterval") {
				_task.complete();
			} else if (command.address == "/polling") {
				_task.complete();
			}
			return _task;
		}

		private function onInputChange(e:Event):void {
			var pinNumber:int = -1;
			var pinValue:Number = 0;

			for (var i:int = 0; i < _digitalPin.length; i++) {
				if (e.target == _digitalPin[i]) {
					pinNumber = i;
					pinValue = _digitalPin[i].value;
					break;
				}
			}

			if (pinNumber < 0) {
				return;
			}

			if (_inputMessage != null) {
				_inputMessage = null;
			}

			_inputMessage = new OSCMessage("/in", new OSCInt(MODULE_ID), new OSCInt(pinNumber));
			_inputMessage.addValue(new OSCFloat(pinValue));
			dispatchEvent(new Event(Event.CHANGE));
		}

	}
}