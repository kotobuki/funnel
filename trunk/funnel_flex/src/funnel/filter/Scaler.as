package funnel.filter
{
	public class Scaler implements IFilter
	{
		public var inMin:Number;
		public var inMax:Number;
		public var outMin:Number;
		public var outMax:Number;
		public var type:Function;
			
		public function Scaler(inMin:Number = 0, inMax:Number = 1, outMin:Number = 0, outMax:Number = 1, type:Function = null) {
			this.inMin = inMin;
			this.inMax = inMax;
			this.outMin = outMin;
			this.outMax = outMax;
			if (type == null) this.type = LINEAR;
			else this.type = type;
		}
		
		public function processSample(val:Number):Number
		{
			var inRange:Number = inMax - inMin;
			var outRange:Number = outMax - outMin;
			var normVal:Number = (val - inMin) / inRange;
			var result:Number = outRange * type(normVal) + outMin;
			//result = Math.max(outMin, Math.min(outMax, result));//出力範囲でクランプ
			return result;
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