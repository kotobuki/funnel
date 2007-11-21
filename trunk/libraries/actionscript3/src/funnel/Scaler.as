package funnel
{
	public class Scaler implements IFilter
	{
		public var inMin:Number;
		public var inMax:Number;
		public var outMin:Number;
		public var outMax:Number;
		public var type:Function;
		public var limiter:Boolean;
			
		public function Scaler(inMin:Number = 0, inMax:Number = 1, outMin:Number = 0, outMax:Number = 1, type:Function = null, limiter:Boolean = false) {
			this.inMin = inMin;
			this.inMax = inMax;
			this.outMin = outMin;
			this.outMax = outMax;
			this.type = (type != null) ? type : LINEAR;
			this.limiter = limiter;
		}
		
		public function processSample(val:Number):Number
		{
			var inRange:Number = inMax - inMin;
			var outRange:Number = outMax - outMin;
			var normVal:Number = (val - inMin) / inRange;
			if (limiter)
				normVal = Math.max(0, Math.min(1, normVal));

			return outRange * type(normVal) + outMin;
		}
		
		public static function LINEAR(val:Number):Number {
			return val;
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