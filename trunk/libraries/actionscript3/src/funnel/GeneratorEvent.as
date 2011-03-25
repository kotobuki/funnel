package funnel
{
	import flash.events.Event;

	/**
	 * This class represents a generator event.
	 * 
	 * <p>ジェネレーターのイベントを表すクラスです。</p>
	 */ 
	public class GeneratorEvent extends Event
	{
		/**
		 * Dispatched when the output value is updated.
		 * 
		 * <p>出力値が更新されたときに送出されます。</p>
		 */
		public static const UPDATE:String = "update";
		
		public function GeneratorEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
	}
}