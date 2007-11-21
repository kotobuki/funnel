package funnel
{
	import flash.events.IEventDispatcher;

	public interface IGenerator extends IEventDispatcher
	{
		function get value():Number;
	}
}