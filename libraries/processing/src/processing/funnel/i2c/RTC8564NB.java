package processing.funnel.i2c;

import processing.funnel.*;

/**
 * @author endo
 * @version 1.0
 * �e�X�g�p
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
		
		//TODO arduino�ȊO�ɑΉ�����Ƃ��́H
		
		Arduino ar = (Arduino)conectedModule.system;
		  byte[] bu = {(byte)0x76,COM_READ,slaveAddress,0x02,0x01};

		ar.sendSysex(bu.length,bu);
	}
	
	
	//�����Ŏ�M�����f�[�^�����W�X�^�A�h���X�����ɐU�蕪��������
	public void receiveData(int regAddress,byte[] data){

		switch(regAddress){
		case 0x02:
			int bcd = data[0]&0x7F; //bcd�`���ibit�����̂܂܂�ށj
	
			second = (bcd>>4)*10+(bcd&0x0F);
		 
//			System.out.println(Integer.toHexString(bcd) + " s");
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

