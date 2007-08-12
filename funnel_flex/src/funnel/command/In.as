package funnel.command
{
	import funnel.osc.*;

	public class In extends OSCMessage
	{
		public function In(startPortNum:uint, count:uint):void {
			super("/in", new OSCInt(startPortNum), new OSCInt(count));
		}
	}
}