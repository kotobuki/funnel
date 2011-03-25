package funnel
{
	/**
	 * Scales up an input value from its min and max range to a specified minimum to maximum range. 
	 * A number of scaling functions are provided.
	 * 
	 * <p>ある範囲の入力をある範囲にスケーリングするためのクラスです。直線でのスケーリング以外に、よく使われるカーブも用意されています。</p>
	 */ 
	public class Scaler implements IFilter
	{
		/**
		 * minimum input
		 * 
		 * <p>入力の最小値</p>
		 * @default 0
		 */		
		public var inMin:Number;
		
		/**
		 * maximum input
		 * 
		 * <p>入力の最大値</p>
		 * @default 1
		 */		
		public var inMax:Number;
		
		/**
		 * minimum output
		 * 
		 * <p>出力の最小値</p>
		 * @default 0
		 */		
		public var outMin:Number;
		
		/**
		 * maximum output
		 * 
		 * <p>出力の最大値</p>
		 * @default 1
		 */		
		public var outMax:Number;
		
		/**
		 * The function used to map the input curve.
		 * 
		* <p>マッピングに使用する曲線を表す関数</p>
		* @default Scaler.LINEAR
		*/		
		public var type:Function;
		
		/**
		 * Sets whether or not to restrict the input value if it exceeds the specified range.
		 * 
		* <p>指定した範囲を超えた入力値を制限するか否か</p>
		* @default false
		*/		
		public var limiter:Boolean;
		
		/**
		 * 
		 * @param inMin minimum input
		 * @param inMax maximum input
		 * @param outMin minimum output
		 * @param outMax maximum output
		 * @param type used to map the input curve
		 * @param limiter whether or not to restrict the input value if it exceeds the specified range
		 * 
		 */		
		public function Scaler(inMin:Number = 0, inMax:Number = 1, outMin:Number = 0, outMax:Number = 1, type:Function = null, limiter:Boolean = true) {
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
		public function processSample(val:Number):Number {
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