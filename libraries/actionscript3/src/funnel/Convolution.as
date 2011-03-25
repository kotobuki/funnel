package funnel
{
	/**
	 * This class performs a convolution operation of the inputs. A low-pass filter is used to remove fine noise and
	 * a high pass filter is used to remove drift.
	 * 
	 * <p>入力に対して畳み込み演算を行うクラスです。細かいノイズを取り除くためのローパスフィルタや、ドリフトを取り除くためのハイパスフィタ等があります。</p>
	 * 
	 */ 
	public class Convolution implements IFilter
	{
		/**
		 * Low-pass filter kernel. Use by passing this array to the constructor. 
		 * 
		 * <p>ローパスフィルタのカーネル。コンストラクタに渡すことで利用します。</p>
	 	 */		
		public static const LPF:Array = [1/3, 1/3, 1/3];
		
		/**
		 * High-pass filter kernel. Use by passing this array to the constructor.
		 * 
		 * <p>ハイパスフィルタのカーネル。コンストラクタに渡すことで利用します。</p>
 		 */
		public static const HPF:Array = [1/3, -2/3, 1/3];
		
		/**
		 * Moving average filter kernel. Use by passing this array to the constructor. 
		 * 
		 * <p>移動平均フィルタのカーネル。コンストラクタに渡すことで利用します。</p>
 		 */
		public static const MOVING_AVERAGE:Array = [1/8, 1/8, 1/8, 1/8, 1/8, 1/8, 1/8, 1/8];
		
		private var _coef:Array;
		private var _buffer:Array;
		
		/**
		 * 
		 * @param kernel An array of coefficients to be used with product-sum operations for input buffers. 
		 * 入力バッファの積和を行う際に用いる係数の配列
		 */		
		public function Convolution(kernel:Array) {
			coef = kernel;
		}
		
		/**
		 * An array of coefficients to be used with product-sum operations for input buffers. If assigned
		 * a new array, the input buffer will be cleared.
		 * 
		 * <p>入力バッファの積和を行う際に用いる係数の配列。代入した場合、バッファはクリアされます。</p>
		 */ 
		public function get coef():Array {
			return _coef;
		}
		
		public function set coef(kernel:Array):void {
			_coef = kernel;
			_buffer = new Array(_coef.length);
			for (var i:uint = 0; i < _buffer.length; i++)
				_buffer[i] = 0;
		}
		
		/**
		 * @inheritDoc
		 * 
		 */		
		public function processSample(val:Number):Number
		{
			_buffer.unshift(val);
			_buffer.pop();
			
			var result:Number = 0;
			for (var i:uint = 0; i < _buffer.length; i++)
				result += _coef[i] * _buffer[i];
			
			return result;
		}
		
	}
}