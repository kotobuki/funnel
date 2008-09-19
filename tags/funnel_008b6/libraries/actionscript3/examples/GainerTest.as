/*
 * Drive a LED with sin wave while the button is pressed.
 *
 * Preparation
 * 1. Connect a LED to aout 0 (current-limiting resistor is needed)
 * 2. Connect a sensor to ain 0 (e.g. a potentiometer)
 *
 * ボタンが押されている間LEDサイン波でドライブする。
 *
 * 準備
 * 1. aout 0にLEDを接続する（電流制限のための抵抗器が必要）
 * 2. ain 0にセンサを接続する（例：ボリューム）
 */

package {
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import funnel.*;
	
	public class GainerTest extends Sprite
	{
		// To change number of analog channels, modify this constant
		// 表示するアナログチャンネル数を変更するにはこの定数を変更する
		private const NUM_CHANNELS:int = 1;

		private var gio:Gainer;
		private var scope:SimpleScope;
		private var scopes:Array;

		public function GainerTest() {
			gio = new Gainer();
			gio.addEventListener(FunnelEvent.READY, trace);
			gio.addEventListener(FunnelErrorEvent.REBOOT_ERROR, trace);
			gio.addEventListener(FunnelErrorEvent.CONFIGURATION_ERROR, trace);
			gio.addEventListener(FunnelErrorEvent.ERROR, trace);

			scopes = new Array(NUM_CHANNELS);
			for (var i:int = 0; i < NUM_CHANNELS; i++) {
				scopes[i] = new SimpleScope(10, 10 + (60 * i), 200);
				addChild(scopes[i]);
			}

			var circle:Shape = new Shape();
			circle.graphics.beginFill(0x000000);
			circle.graphics.drawEllipse(225, 150, 100, 100);
			circle.graphics.endFill();
			circle.visible = false;
			this.addChild(circle);

			var externalLED:Port = gio.analogOutput(0);

			externalLED.filters = [new Osc(Osc.SQUARE, 0.5, 1, 0, 0)];

			gio.button.addEventListener(PortEvent.RISING_EDGE, function(e:Event):void {
				gio.led.value = 1;
				circle.visible = true;
				externalLED.filters[0].reset();
				externalLED.filters[0].start();
			});

			gio.button.addEventListener(PortEvent.FALLING_EDGE, function(e:Event):void {
				gio.led.value = 0;
				circle.visible = false;
				externalLED.filters[0].stop();
				externalLED.value = 0.0;
			});

			addEventListener(Event.ENTER_FRAME, loop);
		}

		private function loop(event:Event):void {
			for (var i:int = 0; i < NUM_CHANNELS; i++) {
				scopes[i].update(gio.analogInput(i).value);
			}
		}
	}
}
