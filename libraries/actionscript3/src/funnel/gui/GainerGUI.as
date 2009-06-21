package funnel.gui {

	import flash.display.Sprite;
	import flash.events.Event;
	import funnel.*;
	import funnel.osc.*;

	public class GainerGUI extends Sprite implements IOnScreenCommandPort {

		private static const MODULE_ID:int = 0;

		private var _ain:Array;

		private var _aout:Array;

		private var _button:OnScreenController;

		private var _din:Array;

		private var _dout:Array;

		private var _inputMessage:OSCMessage;

		private var _led:OnScreenController;

		private var _task:Task;

		public function GainerGUI() {
			super();

			var i:int = 0;
			var offset:int = 0;

			_ain = new Array(Gainer.MODE1.ainPins.length);
			for (i = 0; i < _ain.length; i++) {
				_ain[i] = new OnScreenController("ain " + i, 128, OnScreenController.ANALOG);
				_ain[i].y = offset;
				_ain[i].value = 0;
				_ain[i].addEventListener(Event.CHANGE, onAnalogInputChange);
				addChild(_ain[i]);
				offset += 16;
			}

			offset += 4;
			_din = new Array(Gainer.MODE1.dinPins.length);
			for (i = 0; i < _din.length; i++) {
				_din[i] = new OnScreenController("din " + i, 58, OnScreenController.DIGITAL_TOGGLE);
				_din[i].y = offset;
				_din[i].value = 0;
				_ain[i].addEventListener(Event.CHANGE, onDigitalInputChange);
				addChild(_din[i]);
				offset += 16;
			}

			offset += 4;
			_led = new OnScreenController("LED", 58, OnScreenController.DIGITAL_MOMENTARY);
			_led.x = 128 - 58;
			_led.y = offset;
			_led.value = 0;
			addChild(_led);

			offset = 0;
			_aout = new Array(Gainer.MODE1.aoutPins.length);
			for (i = 0; i < _aout.length; i++) {
				_aout[i] = new OnScreenController("aout " + i, 128, OnScreenController.ANALOG);
				_aout[i].x = 128 + 16;
				_aout[i].y = offset;
				_aout[i].value = 0;
				addChild(_aout[i]);
				offset += 16;
			}

			offset += 4;
			_dout = new Array(Gainer.MODE1.doutPins.length);
			for (i = 0; i < _dout.length; i++) {
				_dout[i] = new OnScreenController("dout " + i, 58, OnScreenController.DIGITAL_TOGGLE);
				_dout[i].x = 128 + 16;
				_dout[i].y = offset;
				_dout[i].value = 0;
				addChild(_dout[i]);
				offset += 16;
			}

			offset += 4;
			_button = new OnScreenController("Button", 58, OnScreenController.DIGITAL_MOMENTARY);
			_button.x = 128 + 16;
			_button.y = offset;
			_button.value = 0;
			_button.addEventListener(Event.CHANGE, onButtonChange);
			addChild(_button);

			dispatchEvent(new FunnelEvent(FunnelEvent.READY));
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
					switch (pinNumber) {
						case Gainer.MODE1.aoutPins[0]:
						case Gainer.MODE1.aoutPins[1]:
						case Gainer.MODE1.aoutPins[2]:
						case Gainer.MODE1.aoutPins[3]:
							_aout[pinNumber - Gainer.MODE1.aoutPins[0]].value = value;
							break;
						case Gainer.MODE1.doutPins[0]:
						case Gainer.MODE1.doutPins[1]:
						case Gainer.MODE1.doutPins[2]:
						case Gainer.MODE1.doutPins[3]:
							_dout[pinNumber - Gainer.MODE1.doutPins[0]].value = value;
							break;
						case Gainer.MODE1.led:
							_led.value = value;
							break;
						default:
							break;
					}
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

		private function onAnalogInputChange(e:Event):void {
			var pinNumber:int = -1;
			var pinValue:Number = 0;

			for (var i:int = 0; i < Gainer.MODE1.ainPins.length; i++) {
				if (e.target == _ain[i]) {
					pinNumber = i + Gainer.MODE1.ainPins[0];
					pinValue = _ain[i].value;
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

		private function onButtonChange(e:Event):void {
			var pinValue:Number = _button.value;

			if (_inputMessage != null) {
				_inputMessage = null;
			}
			_inputMessage = new OSCMessage("/in", new OSCInt(MODULE_ID), new OSCInt(Gainer.MODE1.button));
			_inputMessage.addValue(new OSCFloat(pinValue));
			dispatchEvent(new Event(Event.CHANGE));
		}

		private function onDigitalInputChange(e:Event):void {
			var pinNumber:int = -1;
			var pinValue:Number = 0;

			for (var i:int = 0; i < Gainer.MODE1.dinPins.length; i++) {
				if (e.target == _din[i]) {
					pinNumber = i + Gainer.MODE1.dinPins[0];
					pinValue = _din[i].value;
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