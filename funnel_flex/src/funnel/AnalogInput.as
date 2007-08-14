package funnel
{
	public class AnalogInput extends InputPort
	{
		private var _sampleCount:uint = 0;
		private var _sum:Number = 0;
		
		public function AnalogInput(portNum:uint) {
			super(portNum);
			minimum = Number.MAX_VALUE;
			maximum = 0;
		}
		
		override public function get type():uint {
			return PortType.ANALOG;
		}
		
		override internal function setInputValue(val:Number):void {
			minimum = Math.min(val, minimum);
			maximum = Math.max(val, maximum);
			_sum += val;
			average = _sum / (++_sampleCount);
			super.setInputValue(val);
		}
	}
}