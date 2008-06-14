package {
	import flash.display.Sprite;	
	import flash.events.Event;
	import funnel.*;

	/*
	 * Preparation
	 * 1. Connect a switch to Digital 2 (should be pulled down)
	 * 2. Connect a LED to Digital 11
	 */
	public class ArduinoTest extends Sprite
	{
		public function ArduinoTest() {	
			var config:Configuration = Arduino.FIRMATA;
			config.setDigitalPinMode(11, PWM);

			var aio:Arduino = new Arduino(config);
			aio.addEventListener(FunnelEvent.READY, trace);
			aio.addEventListener(FunnelErrorEvent.REBOOT_ERROR, trace);
			aio.addEventListener(FunnelErrorEvent.CONFIGURATION_ERROR, trace);
			aio.addEventListener(FunnelErrorEvent.ERROR, trace);

			var button:Port = aio.digitalPin(2);
			var led:Port = aio.digitalPin(11);

			led.filters = [new Osc(Osc.SIN, 1, 1, 0, 0)];
			button.addEventListener(PortEvent.RISING_EDGE, function(e:Event):void {
				led.filters[0].start();
			});
			button.addEventListener(PortEvent.FALLING_EDGE, function(e:Event):void {
				led.filters[0].stop();
			});
		}
	}
}
