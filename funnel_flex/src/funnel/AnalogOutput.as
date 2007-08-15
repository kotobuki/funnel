package funnel
{
	public class AnalogOutput extends OutputPort
	{	
		public function AnalogOutput() {
			super();
		}
		
		override public function get type():uint {
			return PortType.ANALOG;
		}
	}
}