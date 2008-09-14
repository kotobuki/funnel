package
{
	import flash.display.Sprite;

	public class SimpleScope extends Sprite
	{
		private var values:Array;
		
		public function SimpleScope(x:Number, y:Number, points:int)
		{
			super();
			this.x = x;
			this.y = y;
			this.values = new Array(points);
			for (var i:int = 0; i < values.length; i++) {
				values[i] = 0.0;
			}
			
			this.graphics.lineStyle(1);
			this.graphics.drawCircle(0, 0, 100);
		}
		
		public function update(newValue:Number):void {		
			this.graphics.clear();
			this.graphics.lineStyle(0.25);
			this.graphics.drawRect(x - 2, y - 2, values.length + 4, 100 + 4);
			this.graphics.lineStyle(0.5);
			this.graphics.moveTo(x, y + 100);
			
			for (var i:int = 0; i < values.length; i++) {
				graphics.lineTo(x + i, y + (1 - values[i]) * 100);
			}

			values.push(newValue);			
			values.shift();
		}
	}
}
