package funnel.ui {
	import funnel.*;

	/**
	 * @copy SoftPotEvent#PRESS
	 */
	[Event(name="press",type="SoftPotEvent")]

	/**
	 * @copy SoftPotEvent#RELEASE
	 */
	[Event(name="release",type="SoftPotEvent")]

	/**
	 * @copy SoftPotEvent#DRAG
	 */
	[Event(name="drag",type="SoftPotEvent")]

	/**
	 * @copy SoftPotEvent#FLICK_UP
	 */
	[Event(name="flickUp",type="SoftPotEvent")]

	/**
	 * @copy SoftPotEvent#FLICK_DOWN
	 */
	[Event(name="flickDown",type="SoftPotEvent")]

	/**
	 * This is the class to express a SoftPot
	 *
	 * @author Shigeru Kobayashi
	 */
	public class SoftPot extends PhysicalInput {
		private var _distanceFromPressed:Number = 0;

		private var _pin:Pin;

		private var _value:Number = 0;

		private var _wasPressed:Boolean = false;

		private var _pressedValue:Number = 0;

		/**
		 *
		 * @param potPin the pin number for a SoftPot
		 */
		public function SoftPot(potPin:Pin) {
			super();

			_pin = potPin;
			_pin.addEventListener(PinEvent.CHANGE, changed);
		}

		/**
		 *
		 * @return the current value
		 */
		public function get value():Number {
			return _value;
		}

		/**
		 * 
		 * @return the current distance from the pressed point
		 */
		public function get distanceFromPressed():Number {
			return _distanceFromPressed;
		}

		/**
		 *
		 * @param minimum the minimum value
		 * @param maximum the minimum value
		 */
		public function setRange(minimum:Number, maximum:Number):void {
			_pin.removeAllFilters();
			_pin.addFilter(new Scaler(minimum, maximum, 0, 1, Scaler.LINEAR));
		}

		private function changed(e:PinEvent):void {
			_value = e.target.value;

			var isPressed:Boolean = (_value < -0.02) ? false : true;

			if (!_wasPressed && isPressed) {
				dispatchEvent(new SoftPotEvent(SoftPotEvent.PRESS));
				_pressedValue = _value;
				_distanceFromPressed = 0;
			} else if (_wasPressed && isPressed) {
				dispatchEvent(new SoftPotEvent(SoftPotEvent.DRAG));
				_distanceFromPressed = _value - _pressedValue;
			} else if (_wasPressed && !isPressed) {
				dispatchEvent(new SoftPotEvent(SoftPotEvent.RELEASE));
			}

			_wasPressed = isPressed;
		}
	}
}