package funnel
{
	import flash.events.Event;
	
	public class OutputPort extends Port
	{
		override public function get direction():uint {
			return PortDirection.OUTPUT;
		}
		
		override public function set value(val:Number):void {
			_value = val;
			dispatchEvent(new Event(PortEvent.UPDATE));
		}
		
	}
}