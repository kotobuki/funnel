package funnel
{
	public class DigitalInput extends Port
	{
		public function DigitalInput(funnel:Funnel, commandPort:CommandPort, portNum:uint) {
			super(funnel, commandPort, portNum);
		}
		
		override public function get direction():uint {
			return PortDirection.INPUT;
		}
		
		override public function get type():uint {
			return PortType.DIGITAL;
		}
		
		internal function setInputValue(val:Number):void {
			detectEdge(val);
		    _value = val;
		}
	}
}