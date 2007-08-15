package funnel
{
	public class AnalogInput extends InputPort
	{
		private var _sampleCount:Number = 0;
		private var _sum:Number = 0;
		private var _average:Number;
		private var _minimum:Number;
		private var _maximum:Number;
		
		public function AnalogInput() {
			super();
			_minimum = 1;
			_maximum = 0;
		}
		
		override public function get type():uint {
			return PortType.ANALOG;
		}
		
		override public function get average():Number {
			return _average;
		}
		
		override public function get minimum():Number {
			return _minimum;
		}
		
		override public function get maximum():Number {
			return _maximum;
		}
		
		override public function clear():void {
			_minimum = _maximum = _average = _value;
			_sum = _sampleCount = 0;
		}
		
		override internal function setInputValue(val:Number):void {
			_minimum = Math.min(val, minimum);
			_maximum = Math.max(val, maximum);
			_sum += val;
			_average = _sum / (++_sampleCount);
			super.setInputValue(val);
		}
		
	}
}