package funnel.ui {
	import flash.events.Event;

	public class SoftPotEvent extends Event {
		public static const PRESS:String = "press";

		public static const RELEASE:String = "release";

		public static const DRAG:String = "drag";

		public static const FLICK_UP:String = "flickUp";

		public static const FLICK_DOWN:String = "flickDown";

		public function SoftPotEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
		}

	}
}