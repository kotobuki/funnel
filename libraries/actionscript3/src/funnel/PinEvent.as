package funnel
{
	import flash.events.Event;
	
	/**
	 * Represents an event related to pin change (such as rising or falling edge).
	 * 
	 * <p>ポート値の変化に関連するイベントを表すクラスです。</p>
	 */ 
	public class PinEvent extends Event
	{
		/**
		 * pin value increasing
		 * <p>ポートの値が0から0以外に変化</p>
		 */	
		public static const RISING_EDGE:String = "risingEdge";
		
		/**
		 * pin value decreasing
		 * <p>ポートの値が0以外から0に変化</p>
		 */		
		public static const FALLING_EDGE:String = "fallingEdge";
		
		/**
		 * pin value changed
		 * <p>ポートの値が変化</p>
		 */	
		public static const CHANGE:String = "change";
		
		public function PinEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
		}
	}
}