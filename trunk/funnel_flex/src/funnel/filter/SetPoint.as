package funnel.filter
{
	public class SetPoint implements IFilter
	{
		public var threshold:Array;
		public var hysteresis:Array;
		private var _lastStatus:int;

		public function SetPoint(threshold:* = 0.5, hysteresis:* = 0) {
			if (threshold is Number)
				threshold = [threshold];
				
			if (hysteresis is Number)
				hysteresis = [hysteresis];

			if (!(threshold is Array) || !(hysteresis is Array))
				throw new Error("threshld and hysteresis should be the same type:(Number or Array)");
				
			if (threshold.length != hysteresis.length)
				throw new Error("threshld and hysteresis should be the same lengths...");
			
			var points:Array = unzip( zip([threshold, hysteresis]).sortOn('0', Array.NUMERIC) );
			this.threshold = points[0];
			this.hysteresis = points[1];
			_lastStatus = 0;
		}
		
		public function processSample(val:Number):Number
		{
			var status:int = threshold.length;
			for (var i:uint = 0; i < threshold.length; ++i) {
				var t:Number = threshold[i];
				var h:Number = hysteresis[i];
				if (val > t+h) continue;
				else if (val < t-h) status = i;
				else status = _lastStatus;
				break;
			}
			_lastStatus = status;
			return status;
		}
		
		private function zip(array:Array):Array {
			var result:Array = [];
			for (var i:uint = 0; i < array[0].length; ++i) {
				var tuple:Array = [];
				for (var j:uint = 0; j < array.length; ++j) {
					tuple.push(array[j][i]);
				}
				result.push(tuple);
			}
			return result;
		}
		
		private function unzip(array:Array):Array {
			var result:Array = [];
			for (var i:uint = 0; i < array[0].length; ++i) {
				var list:Array = [];
				for (var j:uint = 0; j < array.length; ++j) {
					list.push(array[j][i]);
				}
				result.push(list);
			}
			return result;
		}
		
	}
}