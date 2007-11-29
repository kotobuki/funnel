package processing.funnel;

/**
 * @author endo
 * @version 1.0
 * 
 */
public class Convolution implements Filter{

	public float[] coef;
	
	public static final float[] LPF = {1.0f/3, 1.0f/3,1.0f/3};
	public static final float[] HPF = {1.0f/3,-2.0f/3,1.0f/3};
	public static final float[] MOVING_AVERAGE = {1.0f/8,1.0f/8,1.0f/8,1.0f/8,1.0f/8,1.0f/8,1.0f/8,1.0f/8};
	
	public Convolution(float[] kernel){
		coef = new float[kernel.length];
		coef = kernel;
	}
	
	public String getName(){
		return "Convolution";
	}
	public float processSample(float val, float[] buffer){
		
		float v = 0;
		for(int i=0;i<coef.length;i++){
			v += coef[i] * buffer[buffer.length-1-i]; 
		}

		return v;
	}
}
 