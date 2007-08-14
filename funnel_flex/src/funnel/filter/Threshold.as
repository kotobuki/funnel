package funnel.filter
{
	public class Threshold implements IFilter
	{
		private var _lastStatus:int;
		private var _threshold:Number;
		private var _hysteresis:Number;

		public function Threshold(threshold:Number = 0.5, hysteresis:Number = 0) {
			_lastStatus = -1;
			setThreshold(threshold, hysteresis);
		}

		public function processSample(val:Number):Number
		{
			var status:int;
			
			if (val < (_threshold - _hysteresis))
				status = 0;
			else if (val > (_threshold + _hysteresis))
				status = 1;
			else
               	status = _lastStatus;
			
			_lastStatus = status;
			
			return status;
		}
		
		public function setThreshold(threshold:Number, hysteresis:Number):void {
			_threshold = threshold;
			_hysteresis = hysteresis;
		}
		
	}
}