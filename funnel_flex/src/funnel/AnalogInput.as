package funnel
{
	public class AnalogInput extends InputPort
	{
		override public function get type():uint {
			return PortType.ANALOG;
		}
	}
}