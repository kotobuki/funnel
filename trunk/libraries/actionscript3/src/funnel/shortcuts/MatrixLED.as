package funnel.shortcuts 
{
	import funnel.Funnel;
	import flash.display.BitmapData;
	
	public class MatrixLED 
	{
		private var gio:Funnel;
		
		public function MatrixLED(gio:Funnel) {
			this.gio = gio;
		}
		
		public function setPixel(x:uint, y:uint, color:Number):void {
			if (0 <= x && x <= 7 && 0 <= y && y <= 7) {
				gio.analogOutput(y * 8 + x).value = color;
			} 
		}
		
		public function scanMatrix(array:Array):void {
			if (array.length == 64) {
				var tempAutoUpdate:Boolean = gio.autoUpdate;
				gio.autoUpdate = false;
				for (var i:uint = 0; i < 64; ++i) {
					gio.analogOutput(i).value = array[i];
				}
				gio.update();
				gio.autoUpdate = tempAutoUpdate;
			}
		}
	}
}