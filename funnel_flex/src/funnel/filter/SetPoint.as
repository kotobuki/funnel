package funnel.filter
{
	public class SetPoint implements IFilter
	{
		private var _points:Object;
		private var _keys:Array;
		private var _lastStatus:int;

		public function SetPoint(points:Array = null) {
			if (points == null) points = [[0.5, 0]];
			
			_points = new Array();
			for each (var point:Array in points)
				setPoint(point[0], point[1]);

			_lastStatus = 0;
		}
		
		public function processSample(val:Number):Number
		{
			var status:int = _keys.length;
			for (var i:uint = 0; i < _keys.length; ++i) {
				var t:Number = _keys[i];
				var h:Number = _points[t];
				if (val > t+h) continue;
				else if (val < t-h) status = i;
				else status = _lastStatus;
				break;
			}
			_lastStatus = status;
			return status;
		}
		
		//TODO:レンジの重複チェック
		public function setPoint(threshold:Number, hysteresis:Number = 0):void {
			_points[threshold] = hysteresis;
			_keys = getKeys(_points);
		}
		
		public function removePoint(threshold:Number):void {
			delete _points[threshold];
			_keys = getKeys(_points);
		}
		
		private static function getKeys(obj:Object):Array {
			var keys:Array = [];
			for (var key:Object in obj) keys.push(key);
			return keys.sort();
		}
	}
}