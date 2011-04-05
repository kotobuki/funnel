package processing.funnel;


public abstract class Pin{
	public float value;
	public float lastValue = Float.MIN_VALUE;
	
	//
	public float average = 0;
	public float minimum = Float.MAX_VALUE;
	public float maximum = 0;
	
	public abstract void clear();
	
	public abstract void setFilters(Filter[] newFilters);
	
	public abstract void addFilter(Filter newFilter);
	
	public abstract void removeAllFilters();
	
}
