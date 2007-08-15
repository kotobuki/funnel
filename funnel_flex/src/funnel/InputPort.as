package funnel
{
	import funnel.filter.IFilter;
	
	public class InputPort extends Port
	{
		private var _inputAvailable:Boolean;
		
		private var _filters:Array;
		
		public function InputPort()
		{
			super();
			_inputAvailable = false;
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
		
		internal function setInputValue(val:Number):void {
			var filteredValue:Number = applyFilters(val);
			detectEdge(filteredValue);
			_value = filteredValue;
		}
		
		private function detectEdge(val:Number):void {
			if (!edgeDetection) 
				return;
			
			if (!_inputAvailable) {
				_inputAvailable = true;
				return;
			}
			
			if (_value == 0 && val != 0 && onRisingEdge != null)
				onRisingEdge();
			else if (_value != 0 && val == 0 && onFallingEdge != null)
				onFallingEdge();

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