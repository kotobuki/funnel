package funnel
{
	public class DigitalInput extends InputPort
	{
		public function DigitalInput() {
			super();
		}
		
		override public function get type():uint {
			return PortType.DIGITAL;
		}
	}
}