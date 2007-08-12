package funnel
{
	public class DigitalOutput extends Port
	{
		public function DigitalOutput(funnel:Funnel, commandPort:CommandPort, portNum:uint) {
			super(funnel, commandPort, portNum);
		}
			
		override public function get direction():uint {
			return PortDirection.OUTPUT;
		}
		
		override public function get type():uint {
			return PortType.DIGITAL;
		}
		
		override public function set value(val:Number):void {
			_value = val;
			if (_funnel.autoUpadate)
			    update();
		}
	}
}