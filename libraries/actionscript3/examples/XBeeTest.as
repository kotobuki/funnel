/*
 * Display status of AD0/DIO0 as a simple graph.
 *
 * Preparation
 * 1. Connect a sensor to AD0/DIO0 (e.g. a potentiometer)
 *
 * AD0/DIO0の状態をシンプルなグラフとして表示する。
 *
 * 準備
 * 1. AD0/DIO0にセンサを接続する（例：ボリューム）
 */

package {
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import funnel.*;
	
	public class XBeeTest extends Sprite
	{
		// To change number of analog channels, modify this constant
		// 表示するアナログチャンネル数を変更するにはこの定数を変更する
		private const NUM_CHANNELS:int = 1;

		private var xio:XBee;
		private var scope:SimpleScope;
		private var scopes:Array;

		public function XBeeTest() {
			xio = new XBee([1], XBee.MULTIPOINT);
			xio.addEventListener(FunnelEvent.READY, trace);
			xio.addEventListener(FunnelErrorEvent.REBOOT_ERROR, trace);
			xio.addEventListener(FunnelErrorEvent.CONFIGURATION_ERROR, trace);
			xio.addEventListener(FunnelErrorEvent.ERROR, trace);

			scopes = new Array(NUM_CHANNELS);
			for (var i:int = 0; i < NUM_CHANNELS; i++) {
				scopes[i] = new SimpleScope(10, 10 + (60 * i), 200);
				addChild(scopes[i]);
			}

			addEventListener(Event.ENTER_FRAME, loop);
		}
		
		private function loop(event:Event):void {
			for (var i:int = 0; i < NUM_CHANNELS; i++) {
				scopes[i].update(xio.ioModule(1).port(i).value);
			}
		}
	}
}