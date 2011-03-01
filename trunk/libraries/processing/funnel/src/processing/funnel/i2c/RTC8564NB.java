package processing.funnel.i2c;

import processing.funnel.*;

/**
 * @author endo
 * @version 1.0
 * テスト用 RTC-8564NB
 */



//bu[0] = 0x76
//bu[1] = read
//bu[2] = スレーブアドレス
//bu[3] = レジスタ
//bu[4] = 読むバイト数
public class RTC8564NB extends I2CDevice implements I2CInterface{

	static public final String name = "RTC-8564NB";
	
	static private final int slaveAddress = 0x51;
	
	public int second;
	
	
	public RTC8564NB(IOModule iomodule){
		super(iomodule,slaveAddress, name);
		
		iomodule.addI2CDevice(this);
	}
	
	
	public void updateSecond(){

		Firmata io = (Firmata)conectedModule.system;
		  byte[] bu = {COM_I2C_REQUEST,COM_READ,slaveAddress,0x02,0x01};

		io.sendSysex(conectedModule.getModuleID(),bu.length,bu);
	}
	
	
	//ここで受信したデータをレジスタアドレスを元に振り分けをする
	public void receiveData(int regAddress,byte[] data){

		switch(regAddress){
		case 0x02:
			int bcd = data[0]&0x7F; //bcd形式（bitをそのままよむ）
	
			second = (bcd>>4)*10+(bcd&0x0F);
		 
			System.out.println(Integer.toHexString(bcd) + " s");
			break;
		}
	   

	}

	
}

