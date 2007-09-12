package processing.funnel;

public interface Filter {
	
	public float processSample(float in, float[] buffer);
	public String getName();
}
