package funnel.event
{
	import flash.events.Event;
	
	public class PortEvent extends Event
	{
		public static const RISING_EDGE:String = "risingEdge";
		public static const FALLING_EDGE:String = "fallingEdge";
		public static const CHANGE:String = "change";
		
		public var value:Number;
		public var oldValue:Number;
		
		public function PortEvent(type:String, value:Number, oldValue:Number, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			this.value = value;
			this.oldValue = oldValue;
		}
	}
}