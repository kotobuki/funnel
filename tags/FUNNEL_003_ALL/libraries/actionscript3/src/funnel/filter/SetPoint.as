package funnel.filter
{
	public class SetPoint implements IFilter
	{
		private var _points:Object;
		private var _range:Array;
		private var _lastStatus:int;

		public function SetPoint(points:Array = null) {
			if (points == null) points = [[0.5, 0]];
			
			_points = new Array();
			for each (var point:Array in points) _points[point[0]] = point[1];
			updateRange();

			_lastStatus = 0;
		}
		
		public function processSample(val:Number):Number
		{
			var status:int = _lastStatus;
			for (var i:uint = 0; i < _range.length; ++i) {
				var range:Array = _range[i];
				if (range[0] <= val && val <= range[1]) {
					status = i;
					break;
				}
			}
			_lastStatus = status;
			return status;
		}

		public function setPoint(threshold:Number, hysteresis:Number = 0):void {
			_points[threshold] = hysteresis;
			updateRange();
		}
		
		public function removePoint(threshold:Number):void {
			delete _points[threshold];
			updateRange();
		}
		
		private function updateRange():void {
			_range = new Array();
			var keys:Array = getKeys(_points);
			
			var firstKey:Number = keys[0];
			_range.push([Number.NEGATIVE_INFINITY, firstKey - _points[firstKey]]);
			
			for (var i:uint = 0; i < keys.length - 1; ++i) {
				var t0:Number = keys[i];
				var t1:Number = keys[i+1];
				var p0:Number = t0 + _points[t0];
				var p1:Number = t1 - _points[t1];
				if (p0 >= p1) throw new Error("The specified range overlaps...");
				_range.push([p0, p1]);
			}
			
			var lastKey:Number = keys[keys.length - 1];
			_range.push([lastKey + _points[lastKey], Number.POSITIVE_INFINITY]);
		}
		
		private static function getKeys(obj:Object):Array {
			var keys:Array = [];
			for (var key:Object in obj) keys.push(key);
			return keys.sort();
		}
	}
}