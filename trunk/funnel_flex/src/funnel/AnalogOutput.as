package funnel
{
	public class AnalogOutput extends OutputPort
	{	
		override public function get type():uint {
			return PortType.ANALOG;
		}
	}
}