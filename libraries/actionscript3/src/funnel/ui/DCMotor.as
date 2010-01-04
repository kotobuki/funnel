package funnel.ui {
	import funnel.*;

	/**
	 * This is the class to express a H-bridge
	 *
	 * Compatible with:
	 * * TA7291P
	 * * SN754410
	 * * TB6612FNG
	 * * BD6211F
	 *
	 * @author Shigeru Kobayashi
	 */
	public class DCMotor {
		private var _forwardPin:Pin;

		private var _reversePin:Pin;

		private var _pwmPin:Pin;

		private var _value:Number = 0;

		private var _offset:Number = 0;

		private var _range:Number = 0;

		/**
		 *
		 * @param forwardPin
		 * @param reversePin
		 * @param pwmPin
		 * @param minimumVoltage
		 * @param maximumVoltage
		 * @param supplyVoltage
		 */
		public function DCMotor(forwardPin:Pin, reversePin:Pin, pwmPin:Pin, minimumVoltage:Number = 1, maximumVoltage:Number = 9, supplyVoltage:Number = 9) {
			_forwardPin = forwardPin;
			_reversePin = reversePin;
			_pwmPin = pwmPin;

			if (_pwmPin == null) {
				if (_forwardPin.type != PWM) {
					trace("warning: PWM is not available for the forward pin");
				}

				if (_reversePin.type != PWM) {
					trace("warning: PWM is not available for the reverse pin");
				}
			} else {
				if (_pwmPin.type != PWM) {
					trace("warning: PWM is not available for the PWM pin");
				}
			}

			_offset = minimumVoltage / supplyVoltage;
			_range = (maximumVoltage - minimumVoltage) / supplyVoltage;

			despin(false);
		}

		/**
		 *
		 * @return
		 */
		public function get value():Number {
			return _value;
		}

		/**
		 *
		 * @param val
		 */
		public function set value(val:Number):void {
			_value = Math.max(-1, Math.min(1, val));

			if (val > 0) {
				forward(_value);
			} else if (val < 0) {
				reverse(-_value)
			} else {
				despin();
			}
		}

		/**
		 *
		 */
		public function despin(useBrake:Boolean = true):void {
			if (useBrake) {
				if (_pwmPin == null) {
					_forwardPin.value = 1;
					_reversePin.value = 1;
				} else {
					_forwardPin.value = 1;
					_reversePin.value = 1;
					_pwmPin.value = 1;
				}
			} else {
				if (_pwmPin == null) {

					_forwardPin.value = 0;
					_reversePin.value = 0;
				} else {
					_forwardPin.value = 0;
					_reversePin.value = 0;
					_pwmPin.value = 0;
				}
			}
			_value = 0;
		}

		/**
		 *
		 * @param val the new voltage to set
		 */
		public function forward(val:Number = 1):void {
			_value = Math.max(0, Math.min(1, val));

			if (_pwmPin == null) {
				_forwardPin.value = Math.max(0, Math.min(1, _value * _range + _offset));
				_reversePin.value = 0;
			} else {
				_forwardPin.value = 1;
				_reversePin.value = 0;
				_pwmPin.value = Math.max(0, Math.min(1, _value * _range + _offset));
			}
		}

		/**
		 *
		 * @param val the new voltage to set
		 */
		public function reverse(val:Number = 1):void {
			_value = Math.max(0, Math.min(1, val)) * -1;

			if (_pwmPin == null) {
				_forwardPin.value = 0;
				_reversePin.value = Math.max(0, Math.min(1, (_value * _range) * -1 + _offset));
			} else {
				_forwardPin.value = 0;
				_reversePin.value = 1;
				_pwmPin.value = Math.max(0, Math.min(1, (_value * _range) * -1 + _offset));
			}
		}
	}
}
