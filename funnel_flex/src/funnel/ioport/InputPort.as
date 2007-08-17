package funnel.ioport
{
	import flash.events.Event;
	import funnel.filter.IFilter;
	import funnel.event.PortEvent;
	
	public class InputPort extends Port
	{
		private var _inputAvailable:Boolean;
		
		private var _filters:Array;
		
		private static const MAX_SAMPLES:Number = Number.MAX_VALUE;
		private var _numSamples:Number;
		private var _sum:Number;
		private var _average:Number;
		private var _minimum:Number;
		private var _maximum:Number;
		
		public function InputPort()
		{
			super();
			_inputAvailable = false;
			
			_minimum = 1;
			_maximum = 0;
			_average = 0;
			_sum = 0;
			_numSamples = 0;
		}
		
		override public function get direction():uint {
			return PortDirection.INPUT;
		}
		
		override public function get filters():Array {
			return _filters;
		}
		
		override public function set filters(array:Array):void {
			for each (var filter:* in array)
				if (!(filter is IFilter)) return;
			
			_filters = array;
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
			clearWeight();
		}
		
		private function clearWeight():void {
			_sum = _average;
			_numSamples = 1;
		}
		
		override public function set value(val:Number):void {	
			calculateMinimumMaximumAndMean(val);
			var filteredValue:Number = applyFilters(val);
			detectEdge(filteredValue);
			_value = filteredValue;
		}
		
		private function calculateMinimumMaximumAndMean(val:Number):void {
			_minimum = Math.min(val, minimum);
			_maximum = Math.max(val, maximum);
			
			_sum += val;
			_average = _sum / (++_numSamples);
			if (_numSamples >= MAX_SAMPLES)
				clearWeight();
		}
		
		private function detectEdge(val:Number):void {
			if (!_inputAvailable) {
				_inputAvailable = true;
				return;
			}
			
			if (_value == 0 && val != 0)
				dispatchEvent(new Event(PortEvent.RISING_EDGE));
			else if (_value != 0 && val == 0)
				dispatchEvent(new Event(PortEvent.FALLING_EDGE));

		}
		
		private function applyFilters(val:Number):Number {
			if (_filters == null) return val;
			
			var result:Number = val;
			for (var i:uint = 0; i < _filters.length; ++i) 
				result = _filters[i].processSample(result);
			
			return result;
		}
		
	}
}