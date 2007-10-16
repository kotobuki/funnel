package {
	import flash.display.Sprite;	
	import flash.events.Event;
	import funnel.Funnel;
	import funnel.ioport.Port;
	import funnel.event.PortEvent;
	import funnel.filter.Osc;
	import funnel.shortcuts.*;

	public class GainerTest extends Sprite
	{
		public function GainerTest() {	
			var gio:Funnel = new Funnel(GAINER_MODE1);
			var aout0:Port = gio.analogOutput(0);
			aout0.filters = [new Osc(Osc.SIN, 1, 1, 0, 0, 1)];
			gio.button.addEventListener(PortEvent.RISING_EDGE, function(e:Event):void {
				aout0.filters[0].start();
			});
		}
	}
}
