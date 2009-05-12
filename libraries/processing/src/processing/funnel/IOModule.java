
package processing.funnel;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.Set;
import java.util.Vector;

import processing.core.PApplet;

import processing.funnel.i2c.*;

/**
 * @author endo
 * @version 1.0
 * 
 */
public class IOModule{

	Method onRisingEdge = null;
	Method onFallingEdge = null;
	Method onChange = null;

	public IOSystem system;
	
	protected Pin pin[];
	protected int id;
	protected Configuration config;
	
	public String name;
	
	protected HashMap<Integer,I2CInterface> i2cDevs = new HashMap<Integer,I2CInterface>();
	
	//�|�[�g�̋@�\(�Q�Ƃ��閼�O)
	private int analogPin[];
	private int digitalPin[];
	
	
	protected void errorMessage(String message){
		System.out.println(message);
		System.exit(-1);	
	}
	
  
	public IOModule(IOSystem system,int id,Configuration config,String name){
		this.system = system;
		
		PApplet parent = system.parent;
		
		this.id = id;
		this.name = name;
		this.config = config;
		
		int[] conf = config.getPortStatus();
		
		pin = new Pin[conf.length];
		for(int i=0;i<pin.length;i++){
			pin[i] = new Pin(parent,conf[i],i);
		}

		
		//�C�x���g�n���h���̃��t���N�V����
		try {
			onRisingEdge = 
				parent.getClass().getMethod("risingEdge",new Class[] { PinEvent.class });

		} catch (Exception e) {
      // no such method, or an error.. which is fine, just ignore
		}		
	
		try {
			onFallingEdge = 
				parent.getClass().getMethod("fallingEdge",new Class[] { PinEvent.class });
		} catch (Exception e) {
      // no such method, or an error.. which is fine, just ignore
		}	
		
		try {
			onChange = 
				parent.getClass().getMethod("change",new Class[] { PinEvent.class });
			
		} catch (Exception e) {
      // no such method, or an error.. which is fine, just ignore
		}	
	}
	
	protected void setPinAD(int[] _a,int[] _d){
		analogPin = _a;
		digitalPin = _d;
	}
	
	public Pin analogPin(int nPort){
		return pin(analogPin[nPort]);
	}
	
	public Pin digitalPin(int nPort){
		return pin(digitalPin[nPort]);
	}
	
	
	//Port���̂��̂�Ԃ�
	public Pin pin(int nPort){
		if(nPort<pin.length){
			return pin[nPort];
		}
		return null;
	}
	
	public Vector<Integer> getOutputPorts(){
		return config.outputPins;
	}
	
	public int getModuleID(){
		return id;
	}
	
	public void checkOutputPortsUpdated(){
		int[] conf = config.pinsStatus;
		for(int i=0;i<conf.length;i++){
			if((conf[i] & 0x02)==0x2){
				pin(i).checkOutputUpdated();
			}
		}
	}
	
	public boolean addI2CDevice(I2CInterface i2c){
		Set<?> key = i2cDevs.entrySet();
		if(!key.contains(new Integer(i2c.getSlaveAddress()))){

			i2cDevs.put(new Integer(i2c.getSlaveAddress()), i2c);
			
			System.out.println(" addI2CDevice() " + i2c.getName());
			
			return true;
		}
		return false;
	}
	
	public I2CInterface i2cdevice(int slaveAddress){
		
		I2CInterface i2c = (I2CInterface)i2cDevs.get(new Integer(slaveAddress)); 
		return i2c;
	}
	
	
	//
	// 
	public class Pin {

		PApplet parent;
		


		public final int number;//pin �ʂ��ԍ�
		
		public float value;
		public float lastValue;
		
		//
		public float average = 0;
		public float minimum = Float.MAX_VALUE;
		public float maximum = 0;
		
		public Filter filters[];
		
		//
		private float history;
		private int times;
		private final int maxCount = 100;
		
		private LinkedList<Float> buffer;
		private final int bufferSize = 8;
		
		
		public Pin(PApplet parent, int type, int n){
			this.parent = parent;
			number = n;
			
			filters = new Filter[0];
			buffer = new LinkedList<Float>();
			for(int i=0;i<bufferSize;i++){
				buffer.addLast(new Float(0));//dummy
			}

		}
		
		
		public void clear(){
			times = 0;
			minimum = Float.MAX_VALUE;
			maximum = 0;
			average = 0;
			history = 0;
		}
		
		public void checkOutputUpdated(){
			if(this.value != lastValue){
				lastValue = value;
				config.outputPins.add(number);
			}
		}

	
		//���͒l���X�V����
		public void updateInput(float value){
			times++;
			if(times > maxCount){
				history = average;
				times = 2;
			}
			
			minimum = minimum > value ? value : minimum;
			maximum = maximum < value ? value : maximum;
			
			history += value;
			average = history / times;


			
			//�����t�B���^�[���Z�b�g����Ă�����
			//buffer���K�v�Ȃ̂�Convolution�̂�
			if(filters.length == 0 ){
				updateValueInput(value);				

			}else{
				float tempValue = value;
				float fbuf[] = new float[buffer.size()];
				int i;
				for(i=0;i<fbuf.length-1;i++){//LinkedList����float[]��
					Float f = (Float)buffer.get(i+1);					
					fbuf[i] = f.floatValue();
				}

				
				boolean isSetPoint = false;
				for(int n=0;n<filters.length;n++){
					if(filters[n].getName()=="SetPoint"){
						isSetPoint = true;
					}else if(filters[n].getName()=="Convolution"){
						fbuf[i] = tempValue;
						buffer.addLast(new Float(tempValue));
						if(buffer.size()>bufferSize){
							buffer.removeFirst();
						}
					}
					tempValue = filters[n].processSample(tempValue, fbuf);
				}


				updateValueInput(tempValue);
				
				if(isSetPoint ){
					if(onRisingEdge != null  && this.value != 0 && lastValue == 0){
						try{
							onRisingEdge.invoke(parent,new Object[]{ new PinEvent(this) });
						}catch(IllegalAccessException e){
							e.printStackTrace();
						}catch(IllegalArgumentException e){
							e.printStackTrace();
						} catch (InvocationTargetException e) {
							e.printStackTrace();
							onRisingEdge = null;
							errorMessage("onRisingEdge handler error !!");
						}
					}
					
					if(onFallingEdge != null  && lastValue != 0 && this.value == 0){
						try{
							onFallingEdge.invoke(parent,new Object[]{ new PinEvent(this) });
						}catch(IllegalAccessException e){
							e.printStackTrace();
						}catch(IllegalArgumentException e){
							e.printStackTrace();
						} catch (InvocationTargetException e) {
							e.printStackTrace();
							onFallingEdge = null;
							errorMessage("onFallingEdge handler error !!");
						}
					}					
				}


			}
	
		}
		
		//���͒l���X�V����
		protected void updateValueInput(float value){
			lastValue = this.value;
			if(this.value != value){
				this.value = value;

				if(onChange != null && lastValue != this.value){
					try{
						onChange.invoke(parent,new Object[]{ new PinEvent(this) });
					}catch(Exception e){
						e.printStackTrace();
						onChange = null;
						errorMessage("onChange handler error !!");
					}
				}
			}
		}
		
		//�t�B���^�[��ǉ�����
		public void addFilters(Filter[] newFilters){
			
			int filterSize = filters.length + newFilters.length;
			
			Filter[] f = new Filter[filterSize];
			int c=0;
			for(int i=0;i<filters.length;i++){
				f[c++] = filters[i];
			}
			for(int i=0;i<newFilters.length;i++){
				f[c++] = newFilters[i];
			}

			
			filters = f;
		}
		
		public void addFilters(Filter newFilter){
			
			int filterSize = filters.length + 1;
			
			Filter[] f = new Filter[filterSize];
			int i;
			for(i=0;i<filters.length;i++){
				f[i] = filters[i];
			}
			f[i] = newFilter;
			
			filters = f;
		}
		
		
	}
}
