package funnel
{
	import flash.events.ErrorEvent;

	/**
	 * IOSystemのエラーイベントを表すクラスです。
	 */	
	public class FunnelErrorEvent extends ErrorEvent
	{
		/**
		* エラーが起きたとき送出されます。
		*/		
		public static const FATAL_ERROR:String = "fatalError";
		
		/**
		* 指定したコンフィギュレーションの設定に失敗したとき送出されます。
		*/
		public static const CONFIGURATION_ERROR:String = "configurationError";
		
		/**
		* I/Oモジュールの再起動に失敗したとき送出されます。
		*/
		public static const REBOOT_ERROR:String = "rebootError";
		
		public function FunnelErrorEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, text:String="")
		{
			super(type, bubbles, cancelable, text);
		}
		
	}
}