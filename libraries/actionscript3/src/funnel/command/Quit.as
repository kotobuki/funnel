package funnel.command
{
	import funnel.osc.*;

	public class Quit extends OSCMessage
	{
		public function Quit() {
			super("/quit");
		}
	}
}