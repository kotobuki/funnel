package funnel
{
	/**
	 * Divides an input to 0 or 1 based on the threshold and hysteresis. You can also
	 * use multiple points by providing a nested array such as [[0.4, 0.1], [0.7, 0.05]].
	 * 
	 * <p>アナログの値に対して閾値とヒステリシスを持つポイントをセットし、現在の状態を段階化して返します。ポイントが1つの場合の出力は0または1の2種類、ポイントが2つの場合は0または1または2の3種類、ポイントがn個の場合は0からnまでのn種類になります。</p>
	 *
	 */
	public class SetPoint implements IFilter
	{
		private var _points:Array;
		private var _range:Array;
		private var _lastStatus:int;

		/**
		 * Pass array to set initial point. Default threshold is 0.5.
		 * <p>閾値とヒステリシスの2要素からなる配列または配列の配列</p>
		 * 
		 * @param points a two-element array or an array of threshold and hysteresis
		 */
		public function SetPoint(points:Array = null) {
			if (points == null) points = [[0.5, 0]];

			_points = new Array();

			if (points[0] is Array) {
				for each (var point:Array in points) _points[point[0]] = point[1];
			} else if (points[0] is Number) {
				_points[points[0]] = points[1];
			}

			updateRange();

			_lastStatus = 0;
		}

		/**
		 * @inheritDoc
		 */
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

		/**
		 * Add a new point.
		 * <p>新しいポイントを追加する</p>
		 * 
		 * @param threshold the threshold to divide an input to 0 or 1
		 * @param hysteresis the allowance for the threshold
		 */
		public function addPoint(threshold:Number, hysteresis:Number = 0):void {
			_points[threshold] = hysteresis;
			updateRange();
		}

		/**
		 * Remove and delete a point specified by the threshold.
		 * <p>指定した閾値に設定されているポイントを削除する</p>
		 * 
		 * @param threshold the key to remove the threshold point
		 */
		public function removePoint(threshold:Number):void {
			delete _points[threshold];
			updateRange();
		}

		public function removeAllPoints():void {
			_points = new Array();
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