package funnel
{	
	import flash.events.IEventDispatcher;

	/**
	 * @copy GeneratorEvent#UPDATE
	 */
	[Event(name="update",type="GeneratorEvent")]

	/**
	 * Interface for a Generator object.
	 * 
	 * <p>ジェネレーターのインタフェースです。</p>
	 */ 
	public interface IGenerator extends IEventDispatcher
	{
		/**
		 * Get a number that is generated.
		 * 
		 * <p>生成された数値を取得します。</p>
		 * @return number generated
		 * 
		 */		
		function get value():Number;
	}
}