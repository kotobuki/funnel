package funnel
{
	public class DigitalInput extends InputPort
	{
		public function DigitalInput(portNum:uint) {
			super(portNum);
		}
		
		override public function get type():uint {
			return PortType.DIGITAL;
		}
	}
}