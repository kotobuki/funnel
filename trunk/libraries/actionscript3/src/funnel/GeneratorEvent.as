package funnel
{
	import flash.events.Event;

	/**
	 * ジェネレーターのイベントを表すクラスです。
	 */	
	public class GeneratorEvent extends Event
	{
		/**
		* 出力値が更新されたときに送出されます。
		*/
		public static const UPDATE:String = "update";
		
		public function GeneratorEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
	}
}