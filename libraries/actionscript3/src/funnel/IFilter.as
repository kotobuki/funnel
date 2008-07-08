package funnel
{
	/**
	 * フィルタのインタフェースです。
	 */ 
	public interface IFilter
	{
		/**
		 * フィルタを適応します
		 * @param val 入力値
		 * @return フィルタ適応後の値
		 * 
		 */		
		function processSample(val:Number):Number;
	}
}