package {
	import flash.display.Shape;	
	import flash.display.Sprite;	
	import flash.events.Event;
	import funnel.*;

	/*
	 * Preparation
	 * 1. Connect a switch to D12 (should be pulled-up)
	 * 2. Connect a LED to D11
	 */
	public class ArduinoTest extends Sprite
	{
		public function ArduinoTest() {	
			var config:Configuration = Arduino.FIRMATA;
			config.setDigitalPinMode(11, PWM);
			config.setDigitalPinMode(12, IN);
			config.setDigitalPinMode(13, OUT);

			var aio:Arduino = new Arduino(config);

			var circle:Shape = new Shape();
			circle.graphics.beginFill(0x000000);
			circle.graphics.drawEllipse(225, 150, 100, 100);
			circle.graphics.endFill();
			circle.visible = false;
			this.addChild(circle);

			aio.addEventListener(FunnelEvent.READY, trace);
			aio.addEventListener(FunnelErrorEvent.REBOOT_ERROR, trace);
			aio.addEventListener(FunnelErrorEvent.CONFIGURATION_ERROR, trace);
			aio.addEventListener(FunnelErrorEvent.ERROR, trace);

			var button:Port = aio.digitalPin(12);
			var led1:Port = aio.digitalPin(11);
			var led2:Port = aio.digitalPin(13);

			led1.filters = [new Osc(Osc.SIN, 0.5, 1, 0, 0)];
			led2.filters = [new Osc(Osc.SQUARE, 1, 1, 0, 0)];

			button.addEventListener(PortEvent.FALLING_EDGE, function(e:Event):void {
				circle.visible = true;
				led1.filters[0].reset();
				led2.filters[0].reset();
				led1.filters[0].start();
				led2.filters[0].start();
			});

			button.addEventListener(PortEvent.RISING_EDGE, function(e:Event):void {
				circle.visible = false;
				led1.filters[0].stop();
				led2.filters[0].stop();
				led1.value = 0.0;
				led2.value = 0.0;
			});
		}
	}
}
