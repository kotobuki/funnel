package funnel
{
	import flash.events.Event;
	
	/**
	 * IOSystemのイベントを表すクラスです。
	 */ 
	public class FunnelEvent extends Event
	{
		/**
		* I/Oモジュールの初期化が完了したとき送出されます。
		*/
		public static const READY:String = "ready";
	
		public function FunnelEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
	}
}