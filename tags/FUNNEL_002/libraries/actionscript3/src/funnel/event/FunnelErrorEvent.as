package funnel.event
{
	import flash.events.ErrorEvent;

	public class FunnelErrorEvent extends ErrorEvent
	{
		public static const FATAL_ERROR:String = "fatalError";
		public static const CONFIGURATION_ERROR:String = "configurationError";
		public static const REBOOT_ERROR:String = "rebootError";
		
		public function FunnelErrorEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, text:String="")
		{
			super(type, bubbles, cancelable, text);
		}
		
	}
}