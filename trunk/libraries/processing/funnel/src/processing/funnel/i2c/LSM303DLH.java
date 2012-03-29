package processing.funnel.i2c;

import java.io.File;
import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintWriter;

import processing.core.*;
import processing.xml.*;
import processing.funnel.IOModule;
import processing.funnel.Scaler;

/**
 * @author endo
 * @version 1.0
 * 
 */

public class LSM303DLH {
//	public final static String name = "LSM303DLH";

	final byte ACC_ADDRESS = (0x30 >> 1);
	final byte MAG_ADDRESS = (0x3C >> 1);
	final byte CTRL_REG1_A = (0x20);
//	final byte CTRL_REG2_A = (0x21);
//	final byte CTRL_REG3_A = (0x22);
	final byte CTRL_REG4_A = (0x23);
//	final byte CTRL_REG5_A = (0x24);
//	final byte HP_FILTER_RESET_A = (0x25);
//	final byte REFERENCE_A =  (0x26);
//	final byte STATUS_REG_A = (0x27);
	
	final byte OUT_X_L_A = (0x28);
//	final byte OUT_X_H_A = (0x29);
//	final byte OUT_Y_L_A = (0x2A);
//	final byte OUT_Y_H_A = (0x2B);
//	final byte OUT_Z_L_A = (0x2C);
//	final byte OUT_Z_H_A = (0x2D);

//	final byte INT1_CFG_A = (0x30);
//	final byte INT1_SOURCE_A = (0x31);
//	final byte INT1_THS_A = (0x32);
//	final byte INT1_DURATION_A = (0x33);
//	final byte INT2_CFG_A = (0x34);
//	final byte INT2_SOURCE_A = (0x35);
//	final byte INT2_THS_A = (0x36);
//	final byte INT2_DURATION_A = (0x37);

	final byte CRA_REG_M = (0x00);
	final byte CRB_REG_M = (0x01);
	final byte MR_REG_M = (0x02);

	final byte OUT_X_H_M = (0x03);
//	final byte OUT_X_L_M = (0x04);
//	final byte OUT_Y_H_M = (0x05);
//	final byte OUT_Y_L_M = (0x06);
//	final byte OUT_Z_H_M = (0x07);
//	final byte OUT_Z_L_M = (0x08);
//
//	final byte SR_REG_M = (0x09);
//	final byte IRA_REG_M = (0x0A);
//	final byte IRB_REG_M = (0x0B);
//	final byte IRC_REG_M = (0x0C);
	
	private boolean updateCaribrationData = false;
	
	
	Accelerometer a;
	Magnetometer m;
	
	
	
	public LSM303DLH(IOModule iomodule){

		m = new Magnetometer(iomodule);
		iomodule.addI2CDevice(m);

		a = new Accelerometer(iomodule);
		iomodule.addI2CDevice(a);
		
		enable();
		
	}
	
	private void enable(){
		
		m.enable();
		a.enable();
		
		System.out.println("LSM303DLH enabled");

	}
	
	public void reset(){
		m.maximum.x = Float.MIN_VALUE;m.maximum.y = Float.MIN_VALUE; m.maximum.z = Float.MIN_VALUE;
		m.minimum.x = Float.MAX_VALUE;m.minimum.y = Float.MAX_VALUE;m.minimum.z = Float.MAX_VALUE;
	}
	
	public void setCalibration(float min_x,float min_y,float min_z,float max_x,float max_y,float max_z){
		m.maximum.x = max_x;m.maximum.y = max_y; m.maximum.z = max_z;
		m.minimum.x = min_x;m.minimum.y = min_y;m.minimum.z = min_z;
	}
	
	public void printCalibrationData(){
		System.out.println("  min  " + m.minimum.x + "  " + m.minimum.y + "  "+m.minimum.z);
		System.out.println("  max  " + m.maximum.x + "  " + m.maximum.y + "  "+m.maximum.z);
	}
	
	public void enableCalibration(){
		updateCaribrationData = true;
	}
	
	public void disableCalibration(){
		updateCaribrationData = false;
	}
	
	
	public float heading(){
		return heading(new PVector(0,-1,0));
	}
	
	public float heading(PVector from){

		// shift and scale
		PVector pm = new PVector();;
	    pm.x = (m.value.x - m.minimum.x) / (m.maximum.x - m.minimum.x) * 2 - 1.0f;
	    pm.y = (m.value.y - m.minimum.y) / (m.maximum.y - m.minimum.y) * 2 - 1.0f;
	    pm.z = (m.value.z - m.minimum.z) / (m.maximum.z - m.minimum.z) * 2 - 1.0f;


		PVector temp_a = new PVector(a.value.x,a.value.y,a.value.z);
		
	    // normalize
	    temp_a.normalize();
	    
	    // compute E and N
	    PVector E = new PVector();
	    PVector N = new PVector();
	    
	    PVector.cross(pm,temp_a,E);
	    E.normalize();
	    PVector.cross(temp_a,E,N);
	    
	    // compute heading (radians)
	    float heading = PApplet.atan2(E.dot(from),N.dot(from));

		return heading;		

	}
	
	public PVector getAccelerometer(){
		return a.value;
	}
	
	public PVector getMagnetometer(){
		return m.value;
	}
	
	public float[] getCalibrationData(){
		float cal[] = {m.minimum.x,m.minimum.y,m.minimum.z,m.maximum.x,m.maximum.y,m.maximum.z};
		return cal;
	}
	
	
	
	public class Accelerometer extends I2CDevice implements I2CInterface{
		public final static String name = "LSM303DLH(accelmeter)";

		final int SubAddress = OUT_X_L_A | (1 << 7);
		
		public PVector value;
		
		public Accelerometer(IOModule iomodule){
			super(iomodule,ACC_ADDRESS, name);
			
			value = new PVector();
			
		}

		
		@Override
		public void receiveData(int regAddress, byte[] data) {
			switch(regAddress){
			case SubAddress:
				
				byte xla = data[0];
				byte xha = data[1];
				byte yla = data[2];
				byte yha = data[3];
				byte zla = data[4];
				byte zha = data[5];
				
				short xx = (short)(((xha&0xFF)<<8 | (xla&0xFF)));
				
				short yy = (short)(((yha&0xFF)<<8 | (yla&0xFF)));
				
				short zz = (short)(((zha&0xFF)<<8 | (zla&0xFF)));
				
				
				value = new PVector(xx,yy,zz);
				
//				System.out.println("  A  " + value.x + "  " + value.y + "  "+value.z);				
				
				break;
//			case STATUS_REG_A:
//				break;
			}
			

		}
		
		public void enable(){
			beginTransmission();
			send(CTRL_REG1_A);
			//0x27 = 0b00100111 // Normal power mode, all axes enabled
			send((byte)0x27);
			endTransmission();
			
			beginTransmission();
			send(CTRL_REG4_A);
			//0b00110000 +-2g
			send((byte)0x00);
			//0b00110000 8g
			//send((byte)0x30);
			endTransmission();
			
			requestFromRegister(SubAddress,6,true);			
		}
		

	}
	
	
	public class Magnetometer extends I2CDevice implements I2CInterface{
		public final static String name = "LSM303DLH (Magnetometer)";

		
		final int MagnetDataAddress = OUT_X_H_M;

		public PVector value;

		public PVector minimum;
		public PVector maximum;
		
		public Magnetometer(IOModule iomodule){
			super(iomodule,MAG_ADDRESS, name);

			minimum = new PVector(Float.MAX_VALUE,Float.MAX_VALUE,Float.MAX_VALUE);
			maximum = new PVector(Float.MIN_VALUE,Float.MIN_VALUE,Float.MIN_VALUE);
			
			value = new PVector();
			
			requestFromRegister(MagnetDataAddress,6,true);			
		}

		
		@Override
		public void receiveData(int regAddress, byte[] data) {
			switch(regAddress){
			case MagnetDataAddress:
				
				byte xhm = data[0];
				byte xlm = data[1];
				byte yhm = data[2];
				byte ylm = data[3];
				byte zhm = data[4];
				byte zlm = data[5];
				
				short xx = (short)((xhm&0xFF)<<8 | (xlm&0xFF));
				
				short yy = (short)((yhm&0xFF)<<8 | (ylm&0xFF));
				
				short zz = (short)((zhm&0xFF)<<8 | (zlm&0xFF));
				
//				System.out.println("  M  " + xx + "  " + yy + "  "+zz);

				updateValue(xx,yy,zz);
				
				break;
			}

			
				
		}
		
		public void enable(){
			beginTransmission();
			send(CRA_REG_M);
			//0b00011000 data output rate 75Hz
			send((byte)0x18);
			//0b00000000 data output rate 0.75Hz
			//send((byte)0x00);
			endTransmission();
			
			beginTransmission();
			send(CRB_REG_M);
			//0b00100000 1.3gauss
			send((byte)0x20);
			//0b1110000 8.1gauss
//			send((byte)0xE0);
			endTransmission();
			
			beginTransmission();
			send(MR_REG_M);
			//0x00 = 0b00000000
			// Continuous conversion mode
			send((byte)0x00);
			endTransmission();

		}

		private void updateValue(short x,short y,short z){
			
			value = new PVector(x,y,z);
			
						
			if(updateCaribrationData){
				minimum.x = PApplet.min(minimum.x,x);
				maximum.x = PApplet.max(maximum.x,x);
				
				minimum.y = PApplet.min(minimum.y,y);
				maximum.y = PApplet.max(maximum.y,y);
				
				minimum.z = PApplet.min(minimum.z,z);
				maximum.z = PApplet.max(maximum.z,z);			
			}
			
		}

	}
}

