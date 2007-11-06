package funnel 
{
	import funnel.Funnel;
	import flash.display.BitmapData;
	
	public class MatrixLED 
	{
		private var gio:Funnel;
		
		public function MatrixLED(gio:Funnel) {
			this.gio = gio;
		}
		
		public function scanMatrix(image:*):void {
			if (image is BitmapData && image.width == 8 && image.height == 8) {
				var i:uint;
				var j:uint;
				var data:BitmapData = image;
				var pixels:Array = [];
				var r:uint;
				var g:uint;
				var b:uint;
				var rgb:uint;
				for (i = 0; i < 8; ++i) {
					for (j = 0; j < 8; ++j) {
						rgb = data.getPixel(j, i);
						r = ((rgb & 0xff0000) >> 16);
						g = ((rgb & 0xff00) >> 8);
						b = ( rgb & 0xff);  
						pixels.push((0.3*r + 0.59*g + 0.11*b) / 255);
					}
				}
				gio.exportValue(0, pixels);
			} else if (image is Array && image.length == 64) {
				gio.exportValue(0, image);
			}
		}
	}
}