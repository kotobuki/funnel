package funnel
{	
	import flash.events.IEventDispatcher;

	/**
	 * @copy GeneratorEvent#UPDATE
	 */
	[Event(name="update",type="GeneratorEvent")]

	/**
	 * ジェネレーターのインタフェースです。
	 */	
	public interface IGenerator extends IEventDispatcher
	{
		/**
		 * 生成された数値を取得します。
		 * @return 生成された数値
		 * 
		 */		
		function get value():Number;
	}
}