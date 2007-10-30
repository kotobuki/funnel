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
		
		public function scanMatrix(image:*):void {
			if (image is BitmapData) {
				var i:uint;
				var j:uint;
				var data:BitmapData = image;
				image = [];
				var nx:uint = Math.min(data.width, 8);
				var ny:uint = Math.min(data.height, 8);
				var r:uint;
				var g:uint;
				var b:uint;
				var rgb:uint;
				for (i = 0; i < ny; ++i) {
					for (j = 0; j < nx; ++j) {
						rgb = data.getPixel(j, i);
						r = ((rgb & 0xff0000) >> 16);
						g = ((rgb & 0xff00) >> 8);
						b = ( rgb & 0xff);  
						image.push((0.3*r + 0.59*g + 0.11*b) / 255);
					}
				} 
			}
			if (image is Array && image.length <= 64) {
				gio.exportValue(0, image);
			}
		}
	}
}