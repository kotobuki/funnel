package funnel.filter
{
	public class Threshold implements IFilter
	{
		public var threshold:Number;
		public var hysteresis:Number;
		private var _lastStatus:int;

		public function Threshold(threshold:Number = 0.5, hysteresis:Number = 0) {
			this.threshold = threshold;
			this.hysteresis = hysteresis;
			_lastStatus = -1;
		}

		public function processSample(val:Number):Number
		{
			var status:int;
			
			if (val < (threshold - hysteresis))
				status = 0;
			else if (val > (threshold + hysteresis))
				status = 1;
			else
				status = _lastStatus;
			
			_lastStatus = status;
			
			if (status == -1)
				return val; //状態が曖昧なら入力をそのまま返す
			else
				return status;
		}
		
	}
}