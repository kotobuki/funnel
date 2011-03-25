package funnel
{
	/**
	 * Interface for filter objects.
	 * 
	 * <p>フィルタのインタフェースです。</p>
	 */ 
	public interface IFilter
	{
		/**
		 * The adaptive filter.
		 * 
		 * <p>フィルタを適応します</p>
		 * @param val input value
		 * @return resulting value after applying the adaptive filter
		 * 
		 */		
		function processSample(val:Number):Number;
	}
}