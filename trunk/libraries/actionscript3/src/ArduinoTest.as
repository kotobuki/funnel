package {
	import flash.display.Sprite;	
	import flash.events.Event;
	import funnel.Funnel;
	import funnel.ioport.Port;
	import funnel.filter.Osc;
	import funnel.shortcuts.*;

	/*
	 * Preparation
	 * 1. Connect a switch to Digital 2 (should be pulled down)
	 * 2. Connect a LED to Digital 11
	 */
	public class ArduinoTest extends Sprite
	{
		public function ArduinoTest() {	
			var config:Object = ARDUINO;
			config.setDigitalPinMode(0, PWM);

			var aio:Funnel = new Funnel(config);
			aio.addEventListener(READY, trace);
			aio.addEventListener(REBOOT_ERROR, trace);
			aio.addEventListener(CONFIGURATION_ERROR, trace);
			aio.addEventListener(FATAL_ERROR, trace);

			var button:Port = aio.digitalPin(2);
			var led:Port = aio.digitalPin(11);

			led.filters = [new Osc(Osc.SIN, 1, 1, 0, 0)];
			button.addEventListener(RISING_EDGE, function(e:Event):void {
				led.filters[0].start();
			});
			button.addEventListener(FALLING_EDGE, function(e:Event):void {
				led.filters[0].stop();
			});
		}
	}
}
