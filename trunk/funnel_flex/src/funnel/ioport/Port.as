package funnel.ioport
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import funnel.filter.IFilter;
	import funnel.event.PortEvent;
	import funnel.event.GeneratorEvent;
	import funnel.filter.IGenerator;
	
	public class Port extends EventDispatcher
	{
		public static const AIN:uint = 0;
		public static const DIN:uint = 1;
		public static const AOUT:uint = 2;
		public static const DOUT:uint = 3;
		
		protected var _value:Number;
		
		private var _filters:Array;
		private var _generator:IGenerator;
		private var _inputAvailable:Boolean;
		private var _sum:Number;
		private var _average:Number;
		private var _minimum:Number;
		private var _maximum:Number;
		private var _numSamples:Number;
		private static const MAX_SAMPLES:Number = Number.MAX_VALUE;
		
		public function Port() {
			_value = 0;
			_inputAvailable = false;
			_minimum = 1;
			_maximum = 0;
			_average = 0;
			_sum = 0;
			_numSamples = 0;
		}
		
		public static function createWithType(type:uint):Port {
			switch(type) {
				case AIN: return new AnalogInput();
				case DIN: return new DigitalInput();
				case AOUT: return new AnalogOutput();
				case DOUT: return new DigitalOutput();
				default: throw new Error("Type code is illegal...");
			}
		}
		
		public function get direction():uint {
			return undefined;
		}
		
		public function get type():uint {
			return undefined;
		}
		
		public function get value():Number {
			return _value;
		}
		
		public function set value(val:Number):void {
			calculateMinimumMaximumAndMean(val);
			var oldValue:Number = _value;
			_value = applyFilters(val);
			detectEdge(oldValue, _value);
		}
		
		public function get average():Number {
			return _average;
		}
		
		public function get minimum():Number {
			return _minimum;
		}
		
		public function get maximum():Number {
			return _maximum;
		}
		
		public function get filters():Array {
			return _filters;
		}
		
		public function set filters(array:Array):void {
			if (_generator != null)
				_generator.removeEventListener(GeneratorEvent.UPDATE, autoSetValue);
			
			if (array == null || array.length == 0) {
				filters = null;
				return;
			}
			
			var lastIndexOfGenerator:uint = 0;
			for (var i:uint = array.length - 1; i >= 0; --i) {
				if (array[i] is IFilter) {
					;
				} else if (array[i] is IGenerator) {
					lastIndexOfGenerator = i;
					_generator = array[i] as IGenerator;
					_generator.addEventListener(GeneratorEvent.UPDATE, autoSetValue);
					break;
				} else {
					return;
				}
			}
			_filters = array.slice(lastIndexOfGenerator);
		}
		
		private function autoSetValue(event:Event):void {
			value = _generator.value;
		}
		
		public function clear():void {
			_minimum = _maximum = _average = _value;
			clearWeight();
		}
		
		private function clearWeight():void {
			_sum = _average;
			_numSamples = 1;
		}
		
		private function calculateMinimumMaximumAndMean(val:Number):void {
			_minimum = Math.min(val, _minimum);
			_maximum = Math.max(val, _maximum);
			
			_sum += val;
			_average = _sum / (++_numSamples);
			if (_numSamples >= MAX_SAMPLES)
				clearWeight();
		}
		
		private function detectEdge(oldValue:Number, newValue:Number):void {
			if (!_inputAvailable) {
				_inputAvailable = true;
				return;
			}

			if (oldValue == newValue) return;

			dispatchEvent(new PortEvent(PortEvent.CHANGE));
			
			if (oldValue == 0 && newValue != 0)
				dispatchEvent(new PortEvent(PortEvent.RISING_EDGE));
			else if (oldValue != 0 && newValue == 0)
				dispatchEvent(new PortEvent(PortEvent.FALLING_EDGE));

		}
		
		private function applyFilters(val:Number):Number {
			if (_filters == null) return val;
			
			var result:Number = val;
			for (var i:uint = 0; i < _filters.length; ++i) 
				if (_filters[i] is IFilter)
					result = _filters[i].processSample(result);
			
			return result;
		}
		
	}
}