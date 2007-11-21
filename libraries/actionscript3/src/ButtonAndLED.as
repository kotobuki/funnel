package {
	import flash.display.Sprite;	
	import flash.events.Event;
	import funnel.*;
	
	public class ButtonAndLED extends Sprite
	{
		public function ButtonAndLED() {
			var gio:Gainer = new Gainer();
			gio.button.addEventListener(PortEvent.RISING_EDGE, function(e:Event):void {
				gio.led.value = 1;
			});
			gio.button.addEventListener(PortEvent.FALLING_EDGE, function(e:Event):void {
				gio.led.value = 0;
			});
		}
	}
}
