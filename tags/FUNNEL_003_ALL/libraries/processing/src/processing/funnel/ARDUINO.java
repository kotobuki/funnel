package processing.funnel;

import java.util.Arrays;

public class ARDUINO implements IoModule{
	public static final int moduleID = 0x2000;//
	///[outstart1,outnum1,outstart2,outnum2.....]
	private int[] outputPortNumber = new int[0];

	//デジタルポート（設定する名前）
	public static final int IN  = PORT_DIN;
	public static final int OUT = PORT_DOUT;
	public static final int PWM = PORT_AOUT;
	
	private static final int[] firmata = {
		PORT_AIN, PORT_AIN, PORT_AIN, PORT_AIN,PORT_AIN, PORT_AIN,//analog in[0 - 5]
		PORT_DIN, PORT_DIN,PORT_DIN, PORT_DIN,PORT_DIN, PORT_DIN,PORT_DIN, PORT_DIN,
		PORT_DIN, PORT_DIN,PORT_DIN, PORT_DIN,PORT_DIN, PORT_DIN,//digital [0 - 13]
	};
	public static final Configuration FIRMATA = new Configuration(moduleID,firmata);

	
	//ポートの機能(参照する名前)
	public static int analogInput[];
	public static int digitalPin[];
	
	//arduinoのデジタルポート番号からfunnelのポート番号への変換
	public final int[] _digitalPin = {6,7,8,9,10,11,12,13,14,15,16,17,18,19};

	private int[] _ain = {0,1,2,3,4,5};
	private int[] _din = _digitalPin;
	private int[] _dout = {};
	private int[] _pwm = {};
	
	public ARDUINO(){	}
	
	//configを指定どおりに変更しなおす
	public int[] initialize(int[] config){
		if(Arrays.equals(config,firmata)){
			//din
			for(int i=0;i<_din.length;i++){
				config[_din[i]] = PORT_DIN;
			}
			//dout
			for(int i=0;i<_dout.length;i++){
				config[_dout[i]] = PORT_DOUT;
			}
			//pwm
			for(int i=0;i<_pwm.length;i++){
				config[_pwm[i]] = PORT_AOUT;
			}		
		
			analogInput = _ain;
			digitalPin = _digitalPin;

			
		}
		
		return config;
	}
	
	public int[] getOutputPortNumber(){
		return outputPortNumber;
	}
	
	public boolean setDigitalPinMode(int n,int digitalType){

			System.out.println("setDigitalPinMode arduino" + _digitalPin[n]);
			switch(digitalType){
			case ARDUINO.OUT:
				_din = remove(_din,_digitalPin[n]);
				_dout = append(_dout,_digitalPin[n]);
				
				setPort(_dout,_digitalPin[n]);

				break;
			case ARDUINO.PWM:
				_din = remove(_din,_digitalPin[n]);
				_pwm = append(_pwm,_digitalPin[n]);
				
				setPort(_pwm,_digitalPin[n]);
					
				break;
			case ARDUINO.IN:
				break;
			}
			return true;

	}
	
	
	private void setPort(int[] digitalType,int n){

		for(int i=0;i<outputPortNumber.length;i+=2){
			int start = outputPortNumber[i];
			int num = outputPortNumber[i+1];
			if(Math.max(0, start-1)==n){
				outputPortNumber[i] = Math.max(0, start-1);
				outputPortNumber[i+1]++;
				return;
			}else if(start+num == n){
				outputPortNumber[i+1]++;
				return;				
			}
		}
		outputPortNumber = append(outputPortNumber,n);
		outputPortNumber = append(outputPortNumber,1);	
	
	}

  private int[] append(int b[], int value) {

  	int newSize = b.length + 1;
    int temp[] = new int[newSize];
    System.arraycopy(b, 0, temp, 0, Math.min(newSize, b.length));
    
    temp[newSize-1] = value;
    
    return temp;
  }
  
  private int[] remove(int b[], int value){
  	
  	int newSize = b.length - 1;
    int temp[] = new int[newSize];
    
    for(int i=0;i<b.length;i++){
    	if(b[i]==value){
    		System.arraycopy(b, 0, temp, 0,  i);
    		System.arraycopy(b, i+1, temp, i, b.length-i-1);
    		return temp;
    	}
    }

    return b;
  }
}
