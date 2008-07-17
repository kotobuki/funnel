package funnel
{
	/**
	 * 入力に対して畳み込み演算を行うクラスです。細かいノイズを取り除くためのローパスフィルタや、ドリフトを取り除くためのハイパスフィタ等があります。
	 * 
	 */ 
	public class Convolution implements IFilter
	{
		/**
		* ローパスフィルタのカーネル。コンストラクタに渡すことで利用します。
		*/		
		public static const LPF:Array = [1/3, 1/3, 1/3];
		
		/**
		* ハイパスフィルタのカーネル。コンストラクタに渡すことで利用します。
		*/
		public static const HPF:Array = [1/3, -2/3, 1/3];
		
		/**
		* 移動平均フィルタのカーネル。コンストラクタに渡すことで利用します。
		*/
		public static const MOVING_AVERAGE:Array = [1/8, 1/8, 1/8, 1/8, 1/8, 1/8, 1/8, 1/8];
		
		private var _coef:Array;
		private var _buffer:Array;
		
		/**
		 * @param kernel 入力バッファの積和を行う際に用いる係数の配列
		 * 
		 */		
		public function Convolution(kernel:Array) {
			coef = kernel;
		}
		
		/**
		 * 入力バッファの積和を行う際に用いる係数の配列。代入した場合、バッファはクリアされます。
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