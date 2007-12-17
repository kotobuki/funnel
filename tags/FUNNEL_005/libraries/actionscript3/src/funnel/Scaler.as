package funnel
{
	/**
	 * ある範囲の入力をある範囲にスケーリングするためのクラスです。直線でのスケーリング以外に、よく使われるカーブも用意されています。
	 */	
	public class Scaler implements IFilter
	{
		/**
		* 入力の最小値
		* @default 0
		*/		
		public var inMin:Number;
		
		/**
		* 入力の最大値
		* @default 1
		*/		
		public var inMax:Number;
		
		/**
		* 出力の最小値
		* @default 0
		*/		
		public var outMin:Number;
		
		/**
		* 出力の最大値
		* @default 1
		*/		
		public var outMax:Number;
		
		/**
		* マッピングに使用する曲線を表す関数
		* @default Scaler.LINEAR
		*/		
		public var type:Function;
		
		/**
		* 指定した範囲を超えた入力値を制限するか否か
		* @default false
		*/		
		public var limiter:Boolean;
		
		/**
		 * 
		 * @param inMin 入力の最小値
		 * @param inMax 入力の最大値
		 * @param outMin 出力の最小値
		 * @param outMax 出力の最大値
		 * @param type マッピングに使用する曲線
		 * @param limiter 入力値を制限するか
		 * 
		 */		
		public function Scaler(inMin:Number = 0, inMax:Number = 1, outMin:Number = 0, outMax:Number = 1, type:Function = null, limiter:Boolean = false) {
			this.inMin = inMin;
			this.inMax = inMax;
			this.outMin = outMin;
			this.outMax = outMax;
			this.type = (type != null) ? type : LINEAR;
			this.limiter = limiter;
		}
		
		/**
		 * @inheritDoc
		 */		
		public function processSample(val:Number):Number
		{
			var inRange:Number = inMax - inMin;
			var outRange:Number = outMax - outMin;
			var normVal:Number = (val - inMin) / inRange;
			if (limiter)
				normVal = Math.max(0, Math.min(1, normVal));

			return outRange * type(normVal) + outMin;
		}
		
		/**
		 * y = x
		 */		
		public static function LINEAR(val:Number):Number {
			return val;
		}
		
		/**
		 * y = x * x
		 */
		public static function SQUARE(val:Number):Number {
			return val * val;
		}
		
		/**
		 * y = sqrt(x);
		 */
		public static function SQUARE_ROOT(val:Number):Number {
			return Math.pow(val, 0.5);
		}
		
		/**
		 * y = x^4
		 */
		public static function CUBE(val:Number):Number {
			return val * val * val * val;
		}
		
		/**
		 * y = pow(x, 1/4)
		 */
		public static function CUBE_ROOT(val:Number):Number {
			return Math.pow(val, 0.25);
		}
		
	}
}