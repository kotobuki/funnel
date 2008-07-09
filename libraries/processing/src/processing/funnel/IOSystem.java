package processing.funnel;

import java.io.IOException;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.Set;
import java.util.Vector;

import com.illposed.osc.*;
import processing.core.*;

/**
 * @author endo
 * @version 1.0
 * 
 */
public class IOSystem implements Runnable{
	
	PApplet parent;
	
	public static final int PORT_AIN = 0;
	public static final int PORT_DIN = 1;
	public static final int PORT_AOUT = 2;
	public static final int PORT_DOUT = 3;


	protected HashMap iomodules = new HashMap();
	
	private final int TIMEOUT = 1000; 
	private OSCClient client;
	
	/**
	 * autoUpdate=trueの送信時の更新間隔
	 */
	private int updateInterval = 30;	

	private Thread thread=null;
	private boolean isWorking = false;
	

	private boolean quitServer = false;//終了時サーバーを終了するか
	
	//定数
	private int NO_ERROR = 0;
	private int ERROR = -1;
	private int REBOOT_ERROR = -2;
	private int CONFIGURATION_ERROR = -3;

	
	//外部に公開する
	public boolean autoUpdate = false;
	public int samplingInterval;
	////
	
	private boolean waitAnswer;
	private LinkedList waitQueue;

	
	public IOSystem(PApplet parent, String hostName,
			int commandPortNumber,int samplingInterval,Configuration config){
		
		this.parent = parent;
		this.samplingInterval = samplingInterval;

		
		client = new OSCClient();
		if(client.openFunnel(hostName, commandPortNumber)){

			new CommandTokenizer(this,client.commandPort);
			waitQueue = new LinkedList();

		}else{
			errorMessage("Funnel server could not open !");
		}
		
	}
	
	public IOSystem(PApplet parent,Configuration config){
		
		this(parent,"localhost",CommandPort.defaultPort,
				33,config);
	}

	public IOSystem(PApplet parent, int samplingInterval, Configuration config ){
		
		this(parent,"localhost",CommandPort.defaultPort,
				samplingInterval,config);
	}

	public IOSystem(PApplet parent,
			int commandPortNumber, int notifyPortNumber,int samplingInterval,Configuration config ){
		
		this(parent,"localhost",commandPortNumber,
				samplingInterval,config);
	}
	

	//funnelのautupdate==trueに依存
	public void run(){
		long updateTickMillis = 0;
		System.out.println("funnelServiceThread start");

		while(isWorking){
			long processMillis = System.currentTimeMillis() - updateTickMillis;

			if((processMillis > updateInterval) && autoUpdate){
				//OUTPUTのポートの処理
				//System.out.println("update " + processMillis);
				update();
				
				updateTickMillis = System.currentTimeMillis();
				
			}

			try{
				Thread.sleep(1);
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
		
		}
		
		System.out.println("funnelServiceThread out");
	}
	
	public void dispose(){

		//endPolling();
		reboot();
	

		isWorking = false;

			try {
				thread.join();
			} catch (InterruptedException e) {
				e.printStackTrace();
			}


		if(quitServer){
			quit();
		}


		client.cleanOSCPort();	
		
		System.out.println("dispose funnel");
	}
	
	protected void errorMessage(String message){
		System.out.println(message);
		System.exit(-1);	
	}
	
	//samplingIntervalの周期ですべてのポート
	//の分だけ呼び出される（複数回呼び出される）
	private void interpretMessage(OSCMessage message){
		
//			System.out.print("interpret " + message.getAddress() + "   ");
//			for(int i=0;i<message.getArguments().length;i++){
//				System.out.print(message.getArguments()[i] + "   " );
//			}
//			System.out.println( " " );

			int id = ((Integer)message.getArguments()[0]).intValue();
			int n = ((Integer)message.getArguments()[1]).intValue();
			
			IOModule io = (IOModule)iomodules.get(new Integer(id));
			
			for(int i=2;i<message.getArguments().length;i++){
				
				//入力ポートを更新する
				int nPort = n+i-2;
				io.port(nPort).updateInput(((Float)message.getArguments()[i]).floatValue());
	
			}

	}

	private void waitMessage(OSCMessage message){
//		System.out.print("   waitMessage recieve " + message.getAddress() + "   ");
//		for(int i=0;i<message.getArguments().length;i++){
//			System.out.print(message.getArguments()[i] + "   " );
//		}
//		System.out.println( " " );
		
		
		if(waitQueue.lastIndexOf(message.getAddress()) != -1){
			waitAnswer = false;
		}

		if(message.getAddress().equals("/configure")){
			for(int i=0;i<message.getArguments().length;i++){
				int returnCode = ((Integer)message.getArguments()[i]).intValue();
				if( returnCode == NO_ERROR){
					System.out.println("configureation NO_ERROR");
				}else if( returnCode == CONFIGURATION_ERROR){	
					System.out.println("configureation CONFIGURATION_ERROR");
				}else{
					System.out.println("configureation ERROR");
				}
			}
		}
}

	private void execCode(String code,boolean answer){
		//System.out.println("ececCode  " + code);
		try {
			client.sendFunnel(code);
			if(answer){
				client.waitFunnel(code);		
			}
		} catch (IOException e) {
			e.printStackTrace();
		}	
	}
	
	//answer : 戻り値を確認する
	private boolean execCode(String code,Object args[],boolean answer){
		try {
			client.sendFunnel(code,args);
			if(answer){
				waitAnswer = true;
				waitQueue.addLast(code);
				long start = System.currentTimeMillis();
				do{
					long now = System.currentTimeMillis();
					long rest = TIMEOUT - (now-start);
					
					if(rest <= 0){
						System.out.println("timeout return   " +  Thread.currentThread().getName() );
						//throw new TimeoutException("TimeoutException!! " + (now - start));
					}
					client.waitFunnel(code);//!message.getAddress().equals(address)
				}while(waitAnswer);
				
			}				

		}catch (IOException e) {
			e.printStackTrace();
		}
		return true;
	}
	
	public boolean initialize(int moduleID,Configuration config){


		
		reboot();

		if(!configuration(moduleID,config.getPortStatus())){
			return false;
		}
		
		if(!addModule(moduleID,config,config.getModuleName())){
			return false;
		}
		setSamplingInterval(samplingInterval);
	
		
		parent.registerDispose(this);
		return true;
	}
	
	public boolean startIOSystem(){
			
		beginPolling();
		
		thread = new Thread(this,"funnelServiceThread");
		isWorking = true;
		thread.start();
		
		new NotifyTokenizer(this,client.commandPort);
		
		return true;
	}
	
	
	private void reboot(){
		execCode("/reset",true);

	}
	
	private void quit(){
		execCode("/quit",true);
	}
	
	
	private boolean configuration(int id,int[] config){

		Object args[] = new Object[config.length+1];
		args[0] = new Integer(id);
		for(int i=0;i<config.length;i++){
			args[i+1] = new Integer(config[i]);
		}
		
		execCode("/configure",args,true);

		return true;
	}
	
	private void setSamplingInterval(int ms){
		Object args[] = new Object[1];
		args[0] = new Integer(ms);
		
		execCode("/samplingInterval",args,true);

	}
	
	private void beginPolling(){
		Object args[] = new Object[1];
		args[0] = new Integer(1);
		
		execCode("/polling",args,true);

	}

	private void endPolling(){
		Object args[] = new Object[1];
		args[0] = new Integer(0);
		
		execCode("/polling",args,true);	

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
	
	private void outputValues(IOModule io, int startPort,int nPort){
		Object args[] = new Object[nPort+2];
		args[0] = new Integer(io.getModuleID());
		args[1] = new Integer(startPort);
		for(int n=0;n<nPort;n++){
			args[n+2] = new Float(io.port(startPort+n).value);
		}
		execCode("/out",args,true);

	}
	
	public void update(){
		Set keys = iomodules.keySet();
		Iterator it = keys.iterator();
		while(it.hasNext()){
			//モジュール毎
			Integer id = (Integer)it.next();
			IOModule io = (IOModule)iomodules.get(id);
			
			io.checkOutputPortsUpdated();

			Vector oport = io.getOutputPorts();
			int[] outports = new int[oport.size()];
			for(int i=0;i<oport.size();i++){
				Integer iop = (Integer)oport.get(i);
				outports[i] = iop.intValue();
			}
			int start=0;
			int nPort=0;
			for(int i=0;i<outports.length;i++){
				if(nPort==0){
					start = outports[i];
					nPort++;
				}

				if(i == outports.length-1){
					outputValues(io,start,nPort);
					break;
				}else if(outports[i] == outports[i+1]-1 ){
					nPort++;
				}else{
					outputValues(io,start,nPort);
					nPort=0;
				}
			}

			io.getOutputPorts().clear();

		}
	}
	

	
	public boolean addModule(int id,Configuration config,String name){

		Set key = iomodules.entrySet();
		if(!key.contains(new Integer(id))){
			iomodules.put(new Integer(id), new IOModule(parent,id,config,name));
			return true;
		}
		
		return false;
	}
	
	public IOModule iomodule(int id){
		IOModule io = (IOModule)iomodules.get(new Integer(id)); 
		return io;
	}

	
	
	



	//
	//return code tokenizer
	
	class NotifyTokenizer implements OSCListener{
		
		IOSystem io;
		public NotifyTokenizer(IOSystem io,CommandPort port){
			this.io = io;
			port.addListener("/in", this);
			port.startListening();
		}
		public void acceptMessage(Date time, OSCMessage message){
			io.interpretMessage(message);
			
		}
	}
	
	//
	//return code tokenizer
	
	class CommandTokenizer implements OSCListener{
		
		IOSystem io;
		public CommandTokenizer(IOSystem io,CommandPort port){
			this.io = io;
			port.addListener("/reset", this);
			port.addListener("/configure", this);
			port.addListener("/out", this);
			port.addListener("/polling", this);
			port.addListener("/samplingInterval", this);
		}
		public void acceptMessage(Date time, OSCMessage message){
			io.waitMessage(message);
			
		}
	}
	
	
}
