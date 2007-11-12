package funnel.command
{
	import funnel.osc.*;

	public class Polling extends OSCMessage
	{
		public function Polling(beOn:Boolean) {
			super("/polling", new OSCInt(beOn ? 1 : 0));
		}
	}
}