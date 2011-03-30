package funnel.ui {
	import flash.events.Event;

	public class SoftPotEvent2 extends Event {
		public static const PRESS:String = "press";

		public static const RELEASE:String = "release";

		public static const DRAG:String = "drag";

		public static const FLICK_UP:String = "flickUp";
		
		public static const FLICK_DOWN:String = "flickDown";

		public static const TAP:String = "tap";
		
		private var _touchPoint:Number;

		/*
		public function SoftPotEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
		}
		*/
				
		public function SoftPotEvent2(type:String, touchPoint:Number, bubbles:Boolean = false, cancelable:Boolean = false) {			
			super(type, bubbles, cancelable);
			_touchPoint = touchPoint;
		}
		
		// this is mandatory
		override public function clone():Event {
			return new SoftPotEvent2(type, _touchPoint, bubbles, cancelable);
		}		

		public function set value(touchPt:Number):void {
			_touchPoint = touchPt;
		}
		
		public function get value():Number {
			return _touchPoint;
		}		

	}
}