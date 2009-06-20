package funnel.gui {

	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import funnel.*;
	import funnel.osc.*;

	public class GainerGUI extends Sprite implements IOnScreenCommandPort {

		private static const MODULE_ID:int = 0;

		[Embed(source="funnel/gui/GainerGUIComponent.swf")]
		private var GainerGUIComponent:Class;

		private var _ain:Array;

		private var _aout:Array;

		private var _din:Array;

		private var _dout:Array;

		private var _gui:*;

		private var _inputMessage:OSCMessage;

		private var _loader:Loader;

		private var _task:Task;

		public function GainerGUI() {
			super();

			var swf:MovieClip = new GainerGUIComponent();
			addChild(swf);
			Loader(swf.getChildAt(0)).contentLoaderInfo.addEventListener(Event.INIT, initListener);
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
							_aout[pinNumber - Gainer.MODE1.aoutPins[0]].value = value * 255;
							break;
						case Gainer.MODE1.doutPins[0]:
						case Gainer.MODE1.doutPins[1]:
						case Gainer.MODE1.doutPins[2]:
						case Gainer.MODE1.doutPins[3]:
							_dout[pinNumber - Gainer.MODE1.doutPins[0]].selected = (value != 0);
							break;
						case Gainer.MODE1.led:
							_gui.led.selected = (value != 0);
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

		private function initListener(e:Event):void {
			_gui = e.target.content;
			_gui.button.addEventListener(Event.CHANGE, onButtonChange);

			var i:int = 0;

			_ain = new Array(Gainer.MODE1.ainPins.length);
			for (i = 0; i < Gainer.MODE1.ainPins.length; i++) {
				_ain[i] = _gui["ain" + i];
				_ain[i].addEventListener(Event.CHANGE, onAnaligInputChange);
			}

			_din = new Array(Gainer.MODE1.dinPins.length);
			for (i = 0; i < Gainer.MODE1.dinPins.length; i++) {
				_din[i] = _gui["din" + i];
				_din[i].addEventListener(Event.CHANGE, onDigitalInputChange);
			}

			_aout = new Array(Gainer.MODE1.aoutPins.length);
			for (i = 0; i < Gainer.MODE1.aoutPins.length; i++) {
				_aout[i] = _gui["aout" + i];
			}

			_dout = new Array(Gainer.MODE1.doutPins.length);
			for (i = 0; i < Gainer.MODE1.doutPins.length; i++) {
				_dout[i] = _gui["dout" + i];
			}

			dispatchEvent(new FunnelEvent(FunnelEvent.READY));
		}

		private function onAnaligInputChange(e:Event):void {
			var pinNumber:int = -1;
			var pinValue:Number = 0;

			for (var i:int = 0; i < Gainer.MODE1.ainPins.length; i++) {
				if (e.target == _ain[i]) {
					pinNumber = i + Gainer.MODE1.ainPins[0];
					pinValue = _ain[i].value / 255;
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
			var pinValue:Number = 0;
			if (_gui.button.selected) {
				pinValue = 1;
			} else {
				pinValue = 0;
			}

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
					pinValue = _din[i].selected ? 1 : 0;
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