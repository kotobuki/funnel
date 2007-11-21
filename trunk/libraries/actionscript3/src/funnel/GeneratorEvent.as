package funnel
{
	import flash.events.Event;

	public class GeneratorEvent extends Event
	{
		public static const UPDATE:String = "update";
		
		public function GeneratorEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
	}
}