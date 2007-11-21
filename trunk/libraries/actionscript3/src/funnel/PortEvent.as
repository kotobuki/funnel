package funnel
{
	import flash.events.Event;
	
	public class PortEvent extends Event
	{
		public static const RISING_EDGE:String = "risingEdge";
		public static const FALLING_EDGE:String = "fallingEdge";
		public static const CHANGE:String = "change";
		
		public function PortEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
		}
	}
}