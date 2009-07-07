package funnel.ui {

	import funnel.*;

	/**
	 * Created 4 July 2009
	 * By Shigeru Kobayashi
	 *
	 * This is the class to express a servo
	 */
	public class Servo {
		// the scale to convert 0-1 (0-255 in 8bit) to 0-0.706 (0-180 in 8bit)
		private static const COEF_TO_0_180:Number = 180 / 255;

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

			// NOTE: A servo accepts values in 0-180 range instead of the normal range (i.e. 0-255)
			_pin.value = Math.max(0, Math.min(1, (_angle - _minAngle) / (_maxAngle - _minAngle) * COEF_TO_0_180));
		}

	}
}
