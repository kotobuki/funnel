package processing.funnel;


public abstract class Pin{
	public float value;
	public float lastValue;
	
	//
	public float average = 0;
	public float minimum = Float.MAX_VALUE;
	public float maximum = 0;
}
