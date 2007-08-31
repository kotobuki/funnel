package funnel.ioport
{
	import flash.events.Event;
	import funnel.event.PortEvent;
	
	public class OutputPort extends Port
	{
		override public function get direction():uint {
			return PortDirection.OUTPUT;
		}
		
		override public function set value(val:Number):void {
			if (_value == val) return;
			
			_value = val;
			dispatchEvent(new Event(PortEvent.UPDATE));
		}
		
	}
}