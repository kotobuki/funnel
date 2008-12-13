package funnel
{
	import flash.events.Event;
	
	/**
	 * ポート値の変化に関連するイベントを表すクラスです。
	 */ 
	public class PinEvent extends Event
	{
		/**
		* ポートの値が0から0以外に変化
		*/	
		public static const RISING_EDGE:String = "risingEdge";
		
		/**
		* ポートの値が0以外から0に変化
		*/		
		public static const FALLING_EDGE:String = "fallingEdge";
		
		/**
		* ポートの値が変化
		*/	
		public static const CHANGE:String = "change";
		
		public function PinEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
		}
	}
}