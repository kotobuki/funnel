package processing.funnel;


/**
 * @author endo
 * @version 1.0
 * 
 */
public class Scaler implements Filter{

	public float inMin;
	public float inMax;
	public float outMin;
	public float outMax;
	public int type;
	private ScalerFunction typefunc;
	public boolean limiter;
	
	public static final int LINEAR = 1;
//	public static final int LOG = 2;
//	public static final int EXP = 3;
	public static final int SQUARE = 4;
	public static final int SQUARE_ROOT = 5;
	public static final int CUBE = 6;
	public static final int CUBE_ROOT = 7;
	
	public Scaler(float inMin, float inMax, float outMin, float outMax, int type, boolean limiter){
		this.inMin = inMin;
		this.inMax = inMax;
		this.outMin = outMin;
		this.outMax = outMax;
		this.limiter = limiter;
		this.type = type;
		
		switch(type){
		case LINEAR:
			typefunc = new ScalerFunctionLINEAR();
			break;
		case SQUARE:
			typefunc = new ScalerFunctionSQUARE();
			break;
		case SQUARE_ROOT:
			typefunc = new ScalerFunctionSQUARE_ROOT();
			break;
		case CUBE:
			typefunc = new ScalerFunctionCUBE();
			break;
		case CUBE_ROOT:
			typefunc = new ScalerFunctionCUBE_ROOT();
			break;
		default:

			break;
		}
			
		
	}
	
	public Scaler(float inMin, float inMax, float outMin, float outMax){
		this(inMin, inMax, outMin, outMax, LINEAR, false);
	}
	
	/**
	 * return "Scaler"
	 */
	public String getName(){
		return "Scaler";
	}
	
	public float processSample(float val, float[] buffer){
		
		float inRange = inMax - inMin;
		float outRange = outMax - outMin;
		float normVal = (val - inMin) / inRange;
		if(limiter){
			normVal = Math.max(0, Math.min(1,normVal));
		}
		return outRange*typefunc.calculate(normVal)+outMin;
	}
	
	
	interface ScalerFunction{
		
		public float calculate(float val);
	}
	
	class ScalerFunctionLINEAR implements ScalerFunction{
		
		public float calculate(float val){
			return val;
		}
	}
//	class ScalerFunctionLOG implements ScalerFunction{
//		
//		public float calculate(float val){
//			return (float)Math.log(val*(Math.E-1)+1);
//		}
//	}
//	class ScalerFunctionEXP implements ScalerFunction{
//		
//		public float calculate(float val){
//			return (float)((Math.exp(val)-1)/(Math.E-1));
//		}
//	}
	class ScalerFunctionSQUARE implements ScalerFunction{
		
		public float calculate(float val){
			return val*val;
		}
	}
	class ScalerFunctionSQUARE_ROOT implements ScalerFunction{
		
		public float calculate(float val){
			return (float)Math.pow(val, 0.5);
		}
	}
	class ScalerFunctionCUBE implements ScalerFunction{
		
		public float calculate(float val){
			return val*val*val*val;
		}
	}
	class ScalerFunctionCUBE_ROOT implements ScalerFunction{
		
		public float calculate(float val){
			return (float)Math.pow(val,0.25);
		}
	}
}
