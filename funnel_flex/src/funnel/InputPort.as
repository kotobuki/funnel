package funnel
{
	public class InputPort extends Port
	{
		private var _inputAvailable:Boolean;
		
		public function InputPort(portNum:uint)
		{
			super(portNum);
			_inputAvailable = false;
		}
		
		override public function get direction():uint {
			return PortDirection.INPUT;
		}
		
		internal function setInputValue(val:Number):void {
			detectEdge(val);
		    _value = val;
		}
		
		private function detectEdge(val:Number):void {
			if (!edgeDetection) 
				return;
			
			if (!_inputAvailable) {
				_inputAvailable = true;
				return;
			}
			
			if (_value == 0 && val != 0 && onRisingEdge != null) {
				onRisingEdge();
			} else if (_value != 0 && val == 0 && onFallingEdge != null) {
				onFallingEdge();
			}
		}
		
	}
}