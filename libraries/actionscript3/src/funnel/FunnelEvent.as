package funnel
{
	import flash.events.Event;
	
	public class FunnelEvent extends Event
	{
		public static const READY:String = "ready";
	
		public function FunnelEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
	}
}