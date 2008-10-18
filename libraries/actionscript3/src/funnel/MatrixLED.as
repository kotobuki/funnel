package funnel 
{
	import flash.display.BitmapData;
	
	/**
	 * Gainer I/Oモジュールに接続したマトリクスLEDをコントロールするクラスです。
	 */ 
	public class MatrixLED extends IOSystem
	{
		/**
		 * @param host ホスト名
		 * @param portNum ポート番号
		 */		
		public function MatrixLED(host:String = "localhost", portNum:Number = 9000) {
			super([Gainer.MODE7], host, portNum);
		}
		
		/**
		 * 8x8画素のBitmapDataか、64要素のNumber配列からマトリクスLEDの表示内容を更新します。
		 * @param image 8x8画素のBitmapData or 64要素のNumber配列
		 * @see flash.display.BitmapData
		 */		
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
				sendOut(0, 0, pixels);
			} else if (image is Array && image.length == 64) {
				sendOut(0, 0, image);
			}
		}
		
	}
}