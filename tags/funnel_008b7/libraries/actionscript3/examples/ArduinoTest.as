/*
 * Drive a LED with sin wave while the button is pressed.
 *
 * Preparation
 * 1. Connect a button to D12 (should be pulled-up)
 * 2. Connect a LED to D11 (current-limiting resistor is needed)
 * 3. Connect a sensor to A0 (e.g. a potentiometer)
 *
 * ボタンが押されている間LEDサイン波でドライブする。
 *
 * 準備
 * 1. D12にスイッチを接続する（プルアップが必要）
 * 2. D11にLEDを接続する（電流制限のための抵抗器が必要）
 * 3. A0にセンサを接続する（例：ボリューム）
 */

package {
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import funnel.*;

	public class ArduinoTest extends Sprite
	{
		// To change number of analog channels, modify this constant
		// 表示するアナログチャンネル数を変更するにはこの定数を変更する
		private const NUM_CHANNELS:int = 1;

		private var aio:Arduino;
		private var scope:SimpleScope;
		private var scopes:Array;

		public function ArduinoTest() {
			var config:Configuration = Arduino.FIRMATA;
			config.setDigitalPinMode(11, PWM);
			config.setDigitalPinMode(12, IN);
			config.setDigitalPinMode(13, OUT);

			aio = new Arduino(config);
			aio.addEventListener(FunnelEvent.READY, trace);
			aio.addEventListener(FunnelErrorEvent.REBOOT_ERROR, trace);
			aio.addEventListener(FunnelErrorEvent.CONFIGURATION_ERROR, trace);
			aio.addEventListener(FunnelErrorEvent.ERROR, trace);

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

			var button:Port = aio.digitalPin(12);
			var externalLED:Port = aio.digitalPin(11);
			var onBoardLED:Port = aio.digitalPin(13);

			externalLED.filters = [new Osc(Osc.SIN, 0.5, 1, 0, 0)];

			button.addEventListener(PortEvent.FALLING_EDGE, function(e:Event):void {
				onBoardLED.value = 1.0;
				circle.visible = true;
				externalLED.filters[0].reset();
				externalLED.filters[0].start();
			});

			button.addEventListener(PortEvent.RISING_EDGE, function(e:Event):void {
				onBoardLED.value = 0.0;
				circle.visible = false;
				externalLED.filters[0].stop();
				externalLED.value = 0.0;
			});

			addEventListener(Event.ENTER_FRAME, loop);
		}

		private function loop(event:Event):void {
			for (var i:int = 0; i < NUM_CHANNELS; i++) {
				scopes[i].update(aio.analogPin(i).value);
			}
		}
	}
}
