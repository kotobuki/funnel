package {
	import flash.display.*;	
	import flash.events.*;
	import flash.text.*;
	import funnel.*;
	import funnel.filter.*;
	import funnel.ioport.*;
	import funnel.event.*;

	public class FunnelTest extends Sprite
	{
		include "alias.as"
		
		private var fio:Funnel;
		
		public function FunnelTest()
		{	
			fio = new Funnel(GAINER_MODE1);
			/*
			//Funnelのイベントは以下のようにハンドリングする
			fio.addEventListener(READY, function(event:Event):void {
				trace("onReady");
			});
			fio.addEventListener(SERVER_NOT_FOUND_ERROR, function(event:ErrorEvent):void {
				trace("Funnelサーバーが見つかりませんでした");
				//trace(event.text); //エラーイベントの詳細を表示
			});
			*/
			
			//port8の立ち上がりを検出すると、port4に1周期のサイン波を出力する
			fio.port(8).filters = [new Osc(Osc.SIN, 1, 1, 0, 0, 1)];
			fio.port(4).addEventListener(RISING_EDGE, function(e:Event):void {
				fio.port(8).filters[0].start();
			});
			
			//port3にSetPointを設定し、CHANGEイベントと組み合わせて状態遷移の情報をトレースする
			fio.port(3).filters = [ new SetPoint([0.5, 0.7], [0.05, 0.05]) ];
			var stateTransitionMatrix:Array = [
				["0 -> 0", "0 -> 1", "0 -> 2"],
				["1 -> 0", "1 -> 1", "1 -> 2"],
				["2 -> 0", "2 -> 1", "2 -> 2"]
			];
			fio.port(3).addEventListener(CHANGE, function(e:PortEvent):void {
				//PortEventは新旧の値を保持している
				trace(stateTransitionMatrix[e.oldValue][e.value]);
			});

			createView();
		}
		
		private function createView():void {
			//入力値を表示するテキストフィールドを作成
			var tf:TextField = new TextField();
			tf.autoSize = TextFieldAutoSize.LEFT;
			addChild(tf);
			
			//入力値の表示を更新するenterframeイベントハンドラを設定
			addEventListener(Event.ENTER_FRAME, function(event:Event):void {
				var inputInfo:String = "";
				for (var i:uint = 0; i < fio.portCount; ++i) {
					var aPort:Port = fio.port(i);
					if(aPort.direction == INPUT) {
						var pad:String = i < 10 ? "0" : "";
						inputInfo += "port[" + pad + i + "]: ";
						inputInfo += format(aPort.value, 3);
						inputInfo += "    ave: " + format(aPort.average, 3);
						inputInfo += "    min: " + format(aPort.minimum, 3);
						inputInfo += "    max: " + format(aPort.maximum, 3);
						inputInfo += "\n";
					}
				}
				tf.text = inputInfo;
			});
			
			//TODO:出力値を更新するテキストボックスを作成する
		}
		
		private static function format(num:Number, digits:Number):String {
 			if (digits <= 0) {
				return Math.round(num).toString();
			} 
			var tenToPower:Number = Math.pow(10, digits);
			var cropped:String = String(Math.round(num * tenToPower) / tenToPower);
			if (cropped.indexOf(".") == -1) {
				cropped += ".0";
			}

			var halves:Array = cropped.split(".");
			var zerosNeeded:Number = digits - halves[1].length;
			for (var i:uint = 1; i <= zerosNeeded; i++) {
				cropped += "0";
			}
			return(cropped);
		}

	}
}
