package
{
	import flash.display.*;
	import flash.events.Event;
	import funnel.Funnel;
	import funnel.shortcuts.*;
	
	public class MatrixLEDTest extends Sprite
	{
		public function MatrixLEDTest() {
			var gio:Funnel = new Funnel(GAINER_MODE7);
			var mat:MatrixLED = new MatrixLED(gio);
			addEventListener(Event.ENTER_FRAME, function(e:Event):void {
				var pixels:Array = new Array(64);
				for (var i:uint = 0; i < 64; ++i) {
					pixels[i] = Math.random();
				}
				mat.scanMatrix(pixels);
			});
			
		}
	}
}