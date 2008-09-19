/*
 * Drive a LED with square wave and display analog input as a simple graph.
 *
 * Preparation
 * 1. Connect a sensor to A0 (e.g. a potentiometer)
 *
 * LEDを矩形波でドライブしつつアナログ入力の状態をシンプルなグラフに表示する。
 *
 * 準備
 * 1. A0にセンサを接続する（例：ボリューム）
 */

package {
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import funnel.*;
	
	public class FioTest extends Sprite
	{
		// To change number of analog channels, modify this constant
		// 表示するアナログチャンネル数を変更するにはこの定数を変更する
		private const NUM_CHANNELS:int = 1;

		private var fio:Fio;
		private var scope:SimpleScope;
		private var scopes:Array;

		public function FioTest() {
			var config:Configuration = Fio.FIRMATA;
			config.setDigitalPinMode(13, OUT);

			fio = new Fio([1], config);
			fio.addEventListener(FunnelEvent.READY, trace);
			fio.addEventListener(FunnelErrorEvent.REBOOT_ERROR, trace);
			fio.addEventListener(FunnelErrorEvent.CONFIGURATION_ERROR, trace);
			fio.addEventListener(FunnelErrorEvent.ERROR, trace);

			scopes = new Array(NUM_CHANNELS);
			for (var i:int = 0; i < NUM_CHANNELS; i++) {
				scopes[i] = new SimpleScope(10, 10 + (60 * i), 200);
				addChild(scopes[i]);
			}

			var osc:Osc = new Osc(Osc.SQUARE, 0.5, 1, 0, 0);
			fio.ioModule(ALL).digitalPin(13).filters = [osc];
			osc.start();
			
			addEventListener(Event.ENTER_FRAME, loop);
		}
		
		private function loop(event:Event):void {
			for (var i:int = 0; i < NUM_CHANNELS; i++) {
				scopes[i].update(fio.ioModule(1).analogPin(i).value);
			}
		}
	}
}
