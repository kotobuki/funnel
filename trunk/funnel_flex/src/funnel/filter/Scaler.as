package funnel.filter
{
	public class Scaler implements IFilter
	{
		private var _inMin:Number;
		private var _inMax:Number;
		private var _outMin:Number;
		private var _outMax:Number;
		private var _inRange:Number;
		private var _outRange:Number;
		private var _curve:Function;
			
		public function Scaler(inMin:Number = 0, inMax:Number = 1, outMin:Number = 0, outMax:Number = 1, curve:Function = null) {
			_inMin = inMin;
			_inMax = inMax;
			_outMin = outMin;
			_outMax = outMax;
			if (curve == null) _curve = LINEAR;
			else _curve = curve;
			_inRange = inMax - inMin;
			_outRange = outMax - outMin;
		}
		
		public function processSample(val:Number):Number
		{
			var normVal:Number = (val - _inMin) / _inRange;
			normVal = Math.max(0, Math.min(1, normVal));//入力を0-1でクランプ

			return _outRange * _curve(normVal) + _outMin;
		}
		
		public static function LINEAR(val:Number):Number {
			return val;
		}
		
		public static function LOG(val:Number):Number {
			return Math.log(val);
		}
		
		public static function EXP(val:Number):Number {
			return Math.exp(val);
		}
		
		public static function SQUARE(val:Number):Number {
			return val * val;
		}
		
		public static function SQUARE_ROOT(val:Number):Number {
			return Math.pow(val, 0.5);
		}
		
		public static function CUBE(val:Number):Number {
			return val * val * val * val;
		}
		
		public static function CUBE_ROOT(val:Number):Number {
			return Math.pow(val, 0.25);
		}
		
	}
}