package {
	import flash.display.Sprite;	
	import flash.events.Event;
	import funnel.*;
	
	/**
	 * GAINER I/Oモジュール上のボタンを押している間、LEDが点灯するサンプルです。
	 * 
	 */	
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
