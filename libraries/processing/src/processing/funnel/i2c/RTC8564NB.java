package processing.funnel.i2c;

import processing.funnel.*;

/**
 * @author endo
 * @version 1.0
 * �e�X�g�p RTC-8564NB
 */

public class RTC8564NB extends I2CDevice implements I2CInterface{

	public String name = "RTC-8564NB";
	
	private byte slaveAddress = 0x51;
	
	public int second;
	
	
	public RTC8564NB(IOModule io){
		super(io);
		
		io.addI2CDevice(this);
	}
	
	
	public void updateSecond(){

		Firmata io = (Firmata)conectedModule.system;
		  byte[] bu = {COM_I2C_REQUEST,COM_READ,slaveAddress,0x02,0x01};

		io.sendSysex(conectedModule.getModuleID(),bu.length,bu);
	}
	
	
	//�����Ŏ�M�����f�[�^�����W�X�^�A�h���X�����ɐU�蕪��������
	public void receiveData(int regAddress,byte[] data){

		switch(regAddress){
		case 0x02:
			int bcd = data[0]&0x7F; //bcd�`���ibit�����̂܂܂�ށj
	
			second = (bcd>>4)*10+(bcd&0x0F);
		 
			System.out.println(Integer.toHexString(bcd) + " s");
			break;
		}
	   

	}
	
	
	
	public int getSlaveAddress(){
		return slaveAddress;
	}
	
	public String getName(){
		return name;
	}
	
}

