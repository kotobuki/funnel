package funnel.ui {

	import funnel.*;

	/**
	 * Created 4 July 2009
	 * By Shigeru Kobayashi
	 *
	 * This is the class to express a servo
	 */
	public class Servo {
		private var _angle:Number;

		private var _maxAngle:int;

		private var _minAngle:int;

		private var _pin:Pin;

		public function Servo(servoPin:Pin, minAngle:int = 0, maxAngle:int = 180) {
			if (servoPin.type != Pin.SERVO) {
				throw new ArgumentError("Can't attach a servo to a non servo pin. Please set the pin mode of the digital pin " + servoPin.number + " as Servo");
			}

			_pin = servoPin;
			_minAngle = minAngle;
			_maxAngle = maxAngle;
		}

		public function get angle():Number {
			return _angle;
		}

		public function set angle(newAngle:Number):void {
			_angle = newAngle;

			// scale and normalize
			_pin.value = Math.max(0, Math.min(1, (_angle - _minAngle) / (_maxAngle - _minAngle)));
		}

	}
}
