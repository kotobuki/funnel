package funnel.filter
{
	import flash.events.IEventDispatcher;

	public interface IGenerator extends IEventDispatcher
	{
		function get value():Number;
	}
}