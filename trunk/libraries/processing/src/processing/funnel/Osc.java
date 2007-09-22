package processing.funnel;

import java.lang.reflect.Method;
import java.util.*;

import processing.core.*;

public class Osc{

	PApplet parent;
	Method onUpdate;
	
	public static final int SIN = 1;
	public static final int SQUARE = 2;
	public static final int SAW = 3;
	public static final int TRIANGLE = 4;
	public static final int IMPULSE = 5;
	
	
	public static final int UPDATE = 600;
	
	private int wave;//タイプ
	private OscFunction wavefunc;
	
	public float value;
	public float freq;
	public float amplitude;
	public float offset;
	public float phase;
	public int times;
	
	public static int serviceInterval = 1000;
	private static OscThread serviceThread = null;

	private long startTickMillis;//基準の時間
	private long spendTickMillis;
	
	
	
	public Osc(PApplet parent, int wave, float freq, int times){
		
		this(parent,wave,freq,1,0,0,times);
	}
	
	public Osc(PApplet parent, int wave, float freq, float amp, float offset, float phase, int times){

		this.parent = parent;
		
		this.wave = wave;
		this.freq = freq;
		this.amplitude = amp;
		this.offset = offset;
		this.phase = phase;
		this.times = times;
		
		if(freq < 0){
			PApplet.println("Frequency should be larger than 0.");
			parent.exit();
		}
		
		switch(wave){
		case SIN:
			wavefunc = new OscFunctionSIN();
			break;
		case SQUARE:
			wavefunc = new OscFunctionSQUARE();
			break;
		case SAW:
			wavefunc = new OscFunctionSAW();
			break;
		case TRIANGLE:
			wavefunc = new OscFunctionTRIANGLE();
			break;
		case IMPULSE:
			wavefunc = new OscFunctionIMPULSE();
			break;
		default:
			PApplet.println("Error !! Osc function type");
			parent.exit();
			break;
		}
		
		
		
		
		
		if(serviceThread == null || !serviceThread.isAlive()){
			serviceThread = new OscThread(wave);
			serviceThread.startThread();
		}
		
		parent.registerDispose(this);
		
	}
	
	public void dispose(){

		serviceThread.stopThread();
		
		System.out.println("dispose osc");
	}
	
	public void start(){
		startTickMillis = System.currentTimeMillis();
		serviceThread.addOsc(this);
	}
	
	public void stop(){
		serviceThread.removeOsc(this);
	}
	
	public void reset(){
		startTickMillis = System.currentTimeMillis();
		spendTickMillis = 0;
	}
	
	public void addEventListener(int event,String methodName){
			
		if(event == Osc.UPDATE){
			
			try {
				onUpdate = 
					parent.getClass().getMethod(methodName,new Class[] { Osc.class });
			} catch (Exception e) {
				System.out.println(methodName + "が定義されていません");
	      // no such method, or an error.. which is fine, just ignore
			}		
		}else{
			System.out.println("このイベントは追加できません");
		}
	}
	
	public void update(){

		long now = System.currentTimeMillis();
		float sec = (float)(now-startTickMillis)/1000;
		
		if(times != 0 && freq*sec >=times){
			stop();
			sec = times/freq;
		}
		
		value = amplitude * wavefunc.calculate(freq * (sec + phase)) + offset;
		
		if(onUpdate != null  ){
			try{
				onUpdate.invoke(parent,new Object[]{ this });
			}catch(Exception e){
				e.printStackTrace();
				onUpdate = null;
//				errorMessage("onRisingEdge handler error !!");
			}
		}
		
	}
	
	public void update(long millis){
		
		spendTickMillis += millis;
		float sec = (float)(spendTickMillis)/1000;
		
		value = amplitude * wavefunc.calculate(freq * (sec + phase)) + offset;
	}
	
	class OscThread extends Thread{
		boolean isWorking = false;
		long serviceTickMillis;
		List oscList;
		
		public OscThread(int id){
			super("OscServiceThread");
			oscList = Collections.synchronizedList(new LinkedList());
		}
		
		public void startThread(){
			isWorking = true;
			super.start();
		}
		
		public void stopThread(){
			isWorking = false;
			
			if(serviceThread!=null){
				try {
					serviceThread.join();
				} catch (InterruptedException e) {
					// TODO 自動生成された catch ブロック
					e.printStackTrace();
				}
			}
		}
		
		public synchronized void addOsc(Osc osc){
			oscList.add(osc);
		}
		
		public synchronized void removeOsc(Osc osc){
			oscList.remove(osc);
		}
		
		public void run(){
			System.out.println("OscServiceThread start");
			serviceTickMillis = System.currentTimeMillis();
			while(isWorking){
				long now = System.currentTimeMillis();
				if(now - serviceTickMillis > Osc.serviceInterval){
				
					synchronized(oscList){
						ListIterator it = oscList.listIterator();
						for(ListIterator i = it;it.hasNext();){
							
							Osc osc = (Osc)i.next();
							osc.update();
						}
					}
					
					serviceTickMillis = System.currentTimeMillis();
				}

			}
			System.out.println("OscServiceThread out");
		}
	}
	
	interface OscFunction {
		
		public float calculate(float val);
	}
	
	class OscFunctionSIN implements OscFunction{
		
		public float calculate(float val){
			return 0.5f * (float)(1 + Math.sin(2*Math.PI * val));
		}
	}
	
	class OscFunctionSQUARE implements OscFunction{
		
		public float calculate(float val){
			return (val%1 <= 0.5) ? 1.0f: 0;
		}
	}
	
	class OscFunctionTRIANGLE implements OscFunction{
		
		public float calculate(float val){
			val %= 1;
			if(val <= 0.25){
				return 2*val+0.5f;
			}else if(val <= 0.75){
				return -2*val+1.5f;
			}else{
				return 2*val-1.5f;
			}
			
		}
	}
	
	class OscFunctionSAW implements OscFunction{
		
		public float calculate(float val){
			val %=1;
			if(val <0.5){
				return val+0.5f;
			}else{
				return val-0.5f;
			}
		}
	}
	
	class OscFunctionIMPULSE implements OscFunction{
		
		public float calculate(float val){
			if(val <= 1.0){
				return 1.0f;
			}else{
				return 0;
			}
		}
	}
	
}
