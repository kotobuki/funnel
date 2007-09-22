package funnel.command
{
	import funnel.osc.*;

	public class Reset extends OSCMessage
	{
		public function Reset() {
			super("/reset");
		}
	}
}