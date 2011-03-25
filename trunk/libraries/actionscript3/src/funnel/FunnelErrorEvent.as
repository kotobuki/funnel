package funnel
{
	import flash.events.ErrorEvent;

	/**
	 * The error event for the IOSystem.
	 * 
	 * <p>IOSystemのエラーイベントを表すクラスです。</p>
	 */ 
	public class FunnelErrorEvent extends ErrorEvent
	{
		/**
		 * Dispatched when an error occurs.
		 * 
		 * <p>エラーが起きたとき送出されます。</p>
		 */		
		public static const ERROR:String = "error";
		
		/**
		 * Dispatched when configuration settings are not specified.
		 * 
		 * <p>指定したコンフィギュレーションの設定に失敗したとき送出されます</p>。
		 */
		public static const CONFIGURATION_ERROR:String = "configurationError";
		
		/**
		 * Dispatched when an IO error results from a module failing to restart.
		 * 
		* <p>I/Oモジュールの再起動に失敗したとき送出されます。</p>
		*/
		public static const REBOOT_ERROR:String = "rebootError";
		
		public function FunnelErrorEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, text:String="")
		{
			super(type, bubbles, cancelable, text);
		}
		
	}
}