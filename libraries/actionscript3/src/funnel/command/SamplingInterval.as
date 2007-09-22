package funnel.command
{
	import funnel.osc.*;

	public class SamplingInterval extends OSCMessage
	{
		public function SamplingInterval(interval:uint):void {
		    super("/samplingInterval", new OSCInt(interval));
		}
	}
}