package
{
	import flash.display.*;
	import flash.events.Event;
	import flash.geom.Point;
	import funnel.*;

	public class Mode7 extends Sprite
	{
		public function Mode7() {
			var mat:MatrixLED = new MatrixLED();
			var data:BitmapData = new BitmapData(8, 8);
			addChild(new Bitmap(data));
			width = height = 500;
			
			var p:Point = new Point();
			addEventListener(Event.ENTER_FRAME, function(e:Event):void {
				p.x++;
				data.perlinNoise(8, 8, 1, 0, false, false, 7, true, [p]);
				data.draw(data, null, null, BlendMode.ADD);
				mat.scanMatrix(data);
			});
		}
		
	}
}