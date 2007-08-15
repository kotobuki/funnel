package funnel.filter
{
	public class Convolution implements IFilter
	{
		public static const LPH:Array = [1/3, 1/3, 1/3];
		public static const HPF:Array = [1/3, -2/3, 1/3];
		public static const MOVING_AVERAGE:Array = [1/8, 1/8, 1/8, 1/8, 1/8, 1/8, 1/8, 1/8];
		
		private var _coef:Array;
		private var _buffer:Array;
		
		public function Convolution(coef:Array) {
			_coef = coef;
			_buffer = new Array(_coef.length);
		}
		
		public function processSample(val:Number):Number
		{
			_buffer.unshift(val);
			_buffer.pop();
			
			var result:Number = 0;
			for (var i:uint = 0; i < _buffer.length; i++)
				result += _coef[i] * _buffer[i];
			
			return result;
		}
		
	}
}