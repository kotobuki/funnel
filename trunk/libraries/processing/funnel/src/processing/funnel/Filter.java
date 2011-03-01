package processing.funnel;

/**
 * @author endo
 * @version 1.0
 * 
 */
public interface Filter {
	
	public float processSample(float in, float[] buffer);
	public String getName();
}
