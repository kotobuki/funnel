package funnel
{
	public class AnalogOutput extends Port
	{	
		public function AnalogOutput(funnel:Funnel, commandPort:CommandPort, portNum:uint) {
			super(funnel, commandPort, portNum);
		}
		
		override public function get direction():uint {
			return PortDirection.OUTPUT;
		}
		
		override public function get type():uint {
			return PortType.ANALOG;
		}
		
		override public function set value(val:Number):void {
			_value = val;
			if (_funnel.autoUpadate) 
			    update();
		}
	}
}