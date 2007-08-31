package funnel.ioport
{
	public class InputPort extends Port
	{
		override public function get direction():uint {
			return PortDirection.INPUT;
		}
	}
}