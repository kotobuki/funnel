package funnel
{
	public class DigitalOutput extends OutputPort
	{
		public function DigitalOutput() {
			super();
		}
		
		override public function get type():uint {
			return PortType.DIGITAL;
		}
		
		
	}
}