package processing.funnel;


import java.io.IOException;
import java.lang.reflect.*;
import java.util.*;

import processing.core.*;

import com.illposed.osc.*;


public final class Funnel implements Runnable{
	PApplet parent;
	
//	Method onFatalError;
	Method onRisingEdge;
	Method onFallingEdge;
	Method onChange;
	
//	public static final int ON_RISINGEDGE = 100;
//	public static final int ON_FALLINGEDGE = 200;
	
	
	private final int TIMEOUT = 1000; 
	private OSCClient client;
	private Tokenizer tokenizer;
	
	private boolean quitServer = false;//終了時サーバーを終了するか
	
	private Port port[];//funnelのポート
	
	private Thread thread=null;
	private boolean isWorking = false;
	
	private Configuration config;


	//定数
	private int NO_ERROR = 0;
	private int ERROR = -1;
	private int REBOOT_ERROR = -2;
	private int CONFIGURATION_ERROR = -3;
	
	private long updateTickMillis;

	
	//外部に公開する
	public boolean autoUpdate = false;
	public int samplingInterval;


	
	public Funnel(PApplet parent, String hostName,
			int commandPortNumber, int notifyPortNumber,int samplingInterval,Configuration config){
		this.parent = parent;
		this.samplingInterval = samplingInterval;
		config.initialize();
		this.config = config;
		

		
		client = new OSCClient();
		if(client.openFunnel(hostName, commandPortNumber, notifyPortNumber)){
			
			tokenizer = new Tokenizer(this,client.notifyPort);
			
			if(!initialize(config.getPortStatus())){
				errorMessage("Funnel configuration error!");
			}
		}else{
			errorMessage("Funnel server could not open !");
		}
		
	}
	
	public Funnel(PApplet parent,Configuration config){
		
		this(parent,"localhost",CommandPort.defaultPort,NotifyPort.defaultPort,
				33,config);
	}

	public Funnel(PApplet parent, int samplingInterval, Configuration config ){
		
		this(parent,"localhost",CommandPort.defaultPort,NotifyPort.defaultPort,
				samplingInterval,config);
	}

	public Funnel(PApplet parent,
			int commandPortNumber, int notifyPortNumber,int samplingInterval,Configuration config ){
		
		this(parent,"localhost",commandPortNumber,notifyPortNumber,
				samplingInterval,config);
	}
	
	
	
	//funnelのautupdate==trueに依存
	public void run(){
		System.out.println("funnelServiceThread start");

		while(isWorking){
			long now = System.currentTimeMillis();

			//int updateInterval = (int)(1000.0f/parent.frameRate);
			int updateInterval = 30;
			if((now - updateTickMillis > updateInterval) && autoUpdate){
				//OUTPUTのポートの処理
				update();
				
				System.out.println("update!! " + updateInterval + " parent.framerate" + parent.frameRate);
				updateTickMillis = System.currentTimeMillis();
			}
			
		
		}
		System.out.println("funnelServiceThread out");
	}
	
	public void dispose(){

		isWorking = false;
		
		if(thread!=null){
			try {
				thread.join();
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
		}
		
		endPolling();
		
		
		if(quitServer){
			quit();
		}

		client.cleanOSCPort();
		
		System.out.println("dispose funnel");
	}
	
	private void errorMessage(String message){
		System.out.println(message);
		System.exit(-1);	
	}
	
	//samplingIntervalの周期ですべてのポート
	//の分だけ呼び出される（複数回呼び出される）
	private void interpretMessage(OSCMessage message){
		
//		System.out.print("interpret " + message.getAddress() + "   ");
//		for(int i=0;i<message.getArguments().length;i++){
//			System.out.print(message.getArguments()[i] + "   " );
//		}
//		System.out.println( " " );
		
		int n = ((Integer)message.getArguments()[0]).intValue();
		for(int i=1;i<message.getArguments().length;i++){
			
			//入力ポートを更新する
			int nPort = n+i-1;
			port[nPort].update(((Float)message.getArguments()[i]).floatValue());


		}
		
	}


	private void execCode(String code,boolean answer){
		try {
			client.sendFunnel(code);
			if(answer){
				client.readFunnel(code, TIMEOUT);
			}
		} catch(TimeoutException e){
			System.out.println("Timeout exception ");
		} catch (IOException e) {
			e.printStackTrace();
		}	
	}
	
	//answer : 戻り値を確認する
	private OSCMessage execCode(String code,Object args[],boolean answer){
		try {
			client.sendFunnel(code,args);
			if(answer){
				return client.readFunnel(code, TIMEOUT);
			}
		} catch(TimeoutException e){
			System.out.println("Timeout exception ");
		} catch (IOException e) {
			e.printStackTrace();
		}
		return new OSCMessage("nil");
	}
	
	private boolean initialize(int[] config){

		parent.registerDispose(this);

		reboot();
		
		port = new Port[config.length];
		for(int i=0;i<port.length;i++){
			port[i] = new Port(parent,config[i],i);
		}
		
		if(!configuration(config)){
			return false;
		}
		setSamplingInterval(samplingInterval);
	
		

		
		//イベントハンドラのリフレクション
		
//		try {
//			onFatalError = 
//				parent.getClass().getMethod("onFatalError",new Class[] { Integer.TYPE });
//		} catch (Exception e) {
//      // no such method, or an error.. which is fine, just ignore
//		}
		

			try {
				onRisingEdge = 
					parent.getClass().getMethod("risingEdge",new Class[] { PortEvent.class });

			} catch (Exception e) {
	      // no such method, or an error.. which is fine, just ignore
			}		
		
			try {
				onFallingEdge = 
					parent.getClass().getMethod("fallingEdge",new Class[] { PortEvent.class });
			} catch (Exception e) {
	      // no such method, or an error.. which is fine, just ignore
			}	
			
			try {
				onChange = 
					parent.getClass().getMethod("change",new Class[] { PortEvent.class });
				
			} catch (Exception e) {
	      // no such method, or an error.. which is fine, just ignore
			}				

		
		
		thread = new Thread(this,"funnelServiceThread");
		isWorking = true;
		thread.start();
		
		beginPolling();
		
		return true;
	}
	
	
	private void reboot(){
		execCode("/reset",true);
	}
	
	private void quit(){
		execCode("/quit",true);
	}
	
	
	private boolean configuration(int[] config){

		Object args[] = new Object[config.length];
		for(int i=0;i<config.length;i++){
			args[i] = new Integer(config[i]);
		}
		
		OSCMessage message = execCode("/configure",args,true);
		System.out.println(" recieve " + message.getAddress());
		
		for(int i=0;i<message.getArguments().length;i++){
			int returnCode = ((Integer)message.getArguments()[i]).intValue();
			if( returnCode == NO_ERROR){
				System.out.println("configureation NO_ERROR");
			}else if( returnCode == CONFIGURATION_ERROR){	
				System.out.println("configureation CONFIGURATION_ERROR");
				return false;
			}else{
				System.out.println("configureation ERROR");
				return false;
			}
		}

		
		return true;
	}
	
	private void setSamplingInterval(int ms){
		Object args[] = new Object[1];
		args[0] = new Integer(ms);
		
		OSCMessage message = execCode("/samplingInterval",args,true);
		System.out.println(" recieve " + message.getAddress());
	}
	
	private void beginPolling(){
		Object args[] = new Object[1];
		args[0] = new Integer(1);
		
		OSCMessage message = execCode("/polling",args,true);
		System.out.println(" recieve " + message.getAddress());
	}

	private void endPolling(){
		Object args[] = new Object[1];
		args[0] = new Integer(0);
		
		OSCMessage message = execCode("/polling",args,true);	
		System.out.println(" recieve " + message.getAddress());
		
	}
	

//	private void peekOnece(){
//		Object args[] = new Object[2];
//		args[0] = new Integer(0);//指定したポートから
//		args[1] = new Integer(4);//指定したポート数
//		
//		OSCMessage message = execCode("/in",args,true);
//		
//		System.out.print(" /in  ");
//		for(int i=0;i<message.getArguments().length;i++){
//			//int returnCode = ((Integer)message.getArguments()[i]).intValue();
//			System.out.print(message.getArguments()[i] + "  ");
//
//		}
//		System.out.println("");
//		
//	}
	
	
	
	//Digital ０以外は１を出力する
	//Analog  ０以下は０、1以上は１を出力
	public void update(){
		for(int i=0;i<port.length;i++){
			if(port[i].type==Port.DOUT){
				if(port[i].value==0){
					port[i].value = 0.0f;
				}else{
					port[i].value = 1.0f;
				}

			}else if(port[i].type==Port.DIN){
				if(port[i].value<0){
					port[i].value = 0.0f;
				}else if(port[i].value>1.0f){
					port[i].value = 1.0f;
				}
			}
		}
		
		int[] outport = config.getOutputPortNumber();
		for(int i=0;i<outport.length;i+=2){
			
			int start = outport[i];
			int num = outport[i+1];
			Object args[] = new Object[num+1];
			args[0] = new Integer(start);
			for(int n=0;n<num;n++){
				args[n+1] = new Float(port(start+n).value);
			}
			
			OSCMessage message = execCode("/out",args,true);
		}
		
//	Object args[] = new Object[3];
//	args[0] = new Integer(12);
//		args[1] = new Float(1.0f);
//		args[2] = new Float(0.0f);
//	
//	OSCMessage message = execCode("/out",args,false);	

	}
	
	//Portそのものを返す
	public Port port(int nPort){
		if(nPort<port.length){
			return port[nPort];
		}
		return null;
	}
	

	//Gainerショートカット
	public Port analogOutput(int nPort){
		return port(GAINER.analogOutput[nPort]);
	}
	
	public Port analogInput(int nPort){
		return port(GAINER.analogInput[nPort]);
	}
	
	public Port digitalOutput(int nPort){
		return port(GAINER.digitalOutput[nPort]);
	}
	
	public Port digitalInput(int nPort){
		return port(GAINER.digitalInput[nPort]);
	}
	
	//Arduinoショートカット
	public Port analogPin(int nPort){
		return port(ARDUINO.analogInput[nPort]);
	}
	
	public Port digitalPin(int nPort){
		return port(ARDUINO.digitalPin[nPort]);
	}
	
	
	
	//
	// funnel Port
	public class Port {

		PApplet parent;
		
		public final static int AIN = 0x1000;
		public final static int DIN = 0x1100;
		public final static int AOUT = 0x0001;
		public final static int DOUT = 0x0011;
		
		public final int type;
		public final int number;//ポート通し番号
		
		
		
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
		
		private LinkedList buffer;
		private final int bufferSize = 8;
		
		
		//private boolean updated = false;

		
		public Port(PApplet parent, int config, int n){
			this.parent = parent;
			number = n;
			
			filters = new Filter[0];
			buffer = new LinkedList();
			
			switch(config){
			case GAINER.PORT_AIN:
				type = Port.AIN;
				break;
			case GAINER.PORT_AOUT:
				type = Port.AOUT;
				break;
			case GAINER.PORT_DIN:
				type = Port.DIN;
				break;
			case GAINER.PORT_DOUT:
				type = Port.DOUT;
				break;
			default:
				type = -1;
				break;
			}
		}
		
		
		public void clear(){
			times = 0;
			minimum = Float.MAX_VALUE;
			maximum = 0;
			average = 0;
			history = 0;
		}
		
	
		private void update(float value){
			times++;
			if(times > maxCount){
				history = average;
				times = 2;
			}
			
			minimum = minimum > value ? value : minimum;
			maximum = maximum < value ? value : maximum;
			
			history += value;
			average = history / times;
			
			buffer.addLast(new Float(value));
			if(buffer.size()>bufferSize){
				buffer.removeFirst();
			}
			
			//もしフィルターがセットされていたら
			//Bufferに値がないうちは
			//フィルターの処理をしてからvalueの値を決める
			if(filters.length == 0 || buffer.size() < 8){
				updateValue(value);
			}else{
				float tempValue = value;
				float fbuf[] = new float[buffer.size()];
				for(int i=0;i<fbuf.length;i++){//LinkedListからfloat[]へ
					Float f = (Float)buffer.get(i);					
					fbuf[i] = f.floatValue();
				}
				
				boolean isSetPoint = false;
				for(int i=0;i<filters.length;i++){
					if(filters[i].getName()=="SetPoint"){
						isSetPoint = true;
					}
					tempValue = filters[i].processSample(tempValue, fbuf);
				}
		
				if(isSetPoint ){
					if(onRisingEdge != null  && this.value == 0 && tempValue != 0){
						try{
							onRisingEdge.invoke(parent,new Object[]{ new PortEvent(this) });
						}catch(Exception e){
							e.printStackTrace();
							onRisingEdge = null;
							errorMessage("onRisingEdge handler error !!");
						}
					}
					
					if(onFallingEdge != null  && tempValue == 0 && this.value != 0){
						try{
							onFallingEdge.invoke(parent,new Object[]{ new PortEvent(this) });
						}catch(Exception e){
							e.printStackTrace();
							onFallingEdge = null;
							errorMessage("onFallingEdge handler error !!");
						}
					}
					
					if(onChange != null && tempValue != this.value){
						try{
							onChange.invoke(parent,new Object[]{ new PortEvent(this) });
						}catch(Exception e){
							e.printStackTrace();
							onChange = null;
							errorMessage("onChange handler error !!");
						}
					}
					
				}
				updateValue(tempValue);
			}
	
		}
		
		private void updateValue(float value){
			if(this.value != value){
				lastValue = this.value;
				this.value = value;
			}
		}
		
		
	}


	//
	//return code tokenizer
	
	class Tokenizer implements OSCListener{
		
		private Funnel funnel;
		public Tokenizer(Funnel funnel,NotifyPort notifyPort){
			this.funnel = funnel;
			notifyPort.addListener("/in", this);
			notifyPort.startListening();
		}
		public void acceptMessage(Date time, OSCMessage message){

			funnel.interpretMessage(message);

			
		}
	}
	

	
	
	
}
