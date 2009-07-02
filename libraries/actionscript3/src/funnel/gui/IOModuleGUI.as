package funnel.gui {

	import flash.display.Sprite;
	import flash.events.Event;
	
	import funnel.Configuration;
	import funnel.osc.*;

	public class IOModuleGUI extends Sprite {
		public static const MONITOR_MODE:int = 0;

		public static const CONTROLLER_MODE:int = 1;

		protected var _id:int;

		protected var _inputMessage:OSCMessage;

		protected var _mode:int;

		protected var _pin:Array;

		public function IOModuleGUI() {
			super();

			_mode = CONTROLLER_MODE;
		}

		public function configure(id:int, config:Configuration):void {
			throw new ArgumentError("IOModuleGUI.configure() is an abstruct method, should be implemented in derived classes");
		}

		public function handleOutputs(startPinNum:uint, pinValues:Array):void {
			for (var i:int = 0; i < pinValues.length; i++) {
				var value:Number = pinValues[i];
				var pinNumber:int = startPinNum + i;
				_pin[pinNumber].value = value;
			}
		}

		public function get inputMessage():OSCMessage {
			return _inputMessage;
		}

		public function setControllerMode():void {
			_mode = CONTROLLER_MODE;
		}

		public function setMoniorMode():void {
			_mode = MONITOR_MODE;
		}

		public function setValue(pinNumber:int, value:Number):void {
			if (_pin[pinNumber] == null) {
				return;
			}

			_pin[pinNumber].value = value;
		}

		protected function onInputChange(e:Event):void {
			var pinNumber:int = -1;
			var pinValue:Number = 0;

			if (_mode == MONITOR_MODE) {
				return;
			}

			for (var i:int = 0; i < _pin.length; i++) {
				if (e.target == _pin[i]) {
					pinNumber = i;
					pinValue = _pin[i].value;
					break;
				}
			}

			if (pinNumber < 0) {
				return;
			}

			if (_inputMessage != null) {
				_inputMessage = null;
			}

			_inputMessage = new OSCMessage("/in", new OSCInt(_id), new OSCInt(pinNumber));
			_inputMessage.addValue(new OSCFloat(pinValue));
			dispatchEvent(new Event(Event.CHANGE));
		}

	}
}