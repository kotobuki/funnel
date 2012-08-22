package processing.funnel.i2c;


import Jama.*;

import java.lang.Math;

import processing.funnel.IOModule;


/**
 * @author endo
 * @version 1.1
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
	

	public _Accelerometer a;
	public _Magnetometer m;
	
	private double pitch;
	private double roll;
	public float heading;
	
	
	public LSM303DLH(IOModule iomodule){

		m = new _Magnetometer(iomodule);
		iomodule.addI2CDevice(m);

		a = new _Accelerometer(iomodule);
		iomodule.addI2CDevice(a);
		
		enable();
		
	}
	
	private void enable(){
		
		m.enable();
		a.enable();
		
		//System.out.println("LSM303DLH enabled");

	}

	
	
	public class _Accelerometer extends I2CDevice implements I2CInterface{
		public final static String name = "LSM303DLH(accelmeter)";

		final int SubAddress = OUT_X_L_A | (1 << 7);
		

		private Matrix matRowData;
		
		
		
		public _Accelerometer(IOModule iomodule){
			super(iomodule,ACC_ADDRESS, name);
			
			matRowData = new Matrix(1,3);
		}
		

//		//ÃŽ~‚³‚¹‚Ä5‚©‚ç10•bƒf[ƒ^‚ð‹L˜^‚·‚é
//		public boolean setStationaryPosition(int p){
//			//“Ç‚Ýž‚ñ‚Å•½‹Ï‚Æ‚Á‚Ä‹L˜^
//			
//			return true;
//		}

		
		@Override
		public void receiveData(int regAddress, byte[] data) {

			switch(regAddress){
			case SubAddress:
				
				byte lsbX = data[0];
				byte msbX = data[1];
				byte lsbY = data[2];
				byte msbY = data[3];
				byte lsbZ = data[4];
				byte msbZ = data[5];
	
				int ax=0,ay=0,az=0;
				ax |= msbX << 24 & 0xFF000000 | lsbX<< 16 & 0x00F00000;
				ax = (ax>>20);

				ay |= msbY << 24 & 0xFF000000 | lsbY<< 16 & 0x00F00000;
				ay = (ay>>20);
				
				az |= msbZ << 24 & 0xFF000000 | lsbZ<< 16 & 0x00F00000;
				az = (az>>20);

				updateValues(ax,ay,az);
				
				//System.out.println("  A  " + value.x + "  " + value.y + "  "+value.z);
				
				
				break;
//			case STATUS_REG_A:
//				break;
			}
			

		}
		
		public void enable(){
		
			beginTransmission();
				send(CTRL_REG1_A);
				// 0x27 = 0b00100111 // Normal power mode, all axes enabled  37Hz//
				send((byte)0x27);
			endTransmission();
			
			beginTransmission();
				send(CTRL_REG4_A);
				// 0b10110000 +-8g
				send((byte)0xB0);
	
				// 0b10000000 +-2g
				//send((byte)0x80);
			endTransmission();
			
			requestFromRegister(SubAddress,6,true);			
		}
		

		private void updateValues(int x,int y,int z){
			matRowData.set(0, 0, x);
			matRowData.set(0, 1, y);
			matRowData.set(0, 2, z);
			
			matRowData.timesEquals(1.0/matRowData.normF()); //normalize
			
			pitch = Math.asin(-matRowData.get(0, 0));//pitch = asin(-ax)
			roll = Math.asin(matRowData.get(0, 1)/Math.cos(pitch));//roll = asin(ay/cos(pitch))

		}
	}
	
	
	public class _Magnetometer extends I2CDevice implements I2CInterface{
		public final static String name = "LSM303DLH (Magnetometer)";

		
		final int MagnetDataAddress = OUT_X_H_M;
		
		private Matrix matRawData;
		private Matrix matCompensateData;
		private Matrix matTiltCompensatedData;
		
		private Matrix matEllipsoidTransform;
		private Matrix matEllipsoidCenter;
		
		public _Magnetometer(IOModule iomodule){
			super(iomodule,MAG_ADDRESS, name);

		
			matRawData = new Matrix(3,1);
			matCompensateData = new Matrix(3,1);
			matTiltCompensatedData = new Matrix(3,1);
			
//			double[][] dt = {{0.871045, 0.0341145, -0.00556378}, {0.0341145, 0.912459, -0.0491539}, {-0.00556378, -0.0491539, 0.967118}};
//			matEllipsoidTransform = new Matrix(dt);
//			double[] dc = {-69.1986, 97.7790, 130.019};
//			matEllipsoidCenter = new Matrix(dc,3);
			
			matEllipsoidTransform = Matrix.identity(3, 3);
			matEllipsoidCenter = new Matrix(3,1);
			
		}
		
		public double[] getRawData(){
			return matRawData.getColumnPackedCopy();
		}
		
		public double[] getCompensateData(){
			return matCompensateData.getColumnPackedCopy();
		}
		
		public void setEllipsoidTransformMatrix(double[][] dt){
			matEllipsoidTransform = new Matrix(dt);
		}
		
		public void setEllipsoidCenter(double[] dc){
			matEllipsoidCenter = new Matrix(dc,3);
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
				
				int mx=0,my=0,mz=0;
				mx = (xhm<<24) & 0xFF000000 | (xlm<<16) & 0x00FF0000;
				mx = (mx>>16);
				my = (yhm<<24) & 0xFF000000 | (ylm<<16) & 0x00FF0000;
				my = (my>>16);
				mz = (zhm<<24) & 0xFF000000 | (zlm<<16) & 0x00FF0000;
				mz = (mz>>16);
				
				//System.out.println("  M  " + mx + "  " + my + "  "+mz);

				updateValue(mx,my,mz);
				
				break;
			}
		}
		
		public void enable(){
			beginTransmission();
				send(CRA_REG_M);
				send((byte)0x18);//0b00011000 data output rate 75Hz
				//send((byte)0x00);//0b00000000 data output rate 0.75Hz
			endTransmission();
			
			beginTransmission();
				send(CRB_REG_M);
				//0b00100000 1.3gauss
				send((byte)0x20);
				//0b1110000 8.1gauss
				//send((byte)0xE0);
			endTransmission();
			
			beginTransmission();
				send(MR_REG_M);
				//0x00 = 0b00000000
				// Continuous conversion mode
				send((byte)0x00);
			endTransmission();
			
			requestFromRegister(MagnetDataAddress,6,true);

		}

		private void updateValue(int x,int y,int z){
			
			matRawData.set(0, 0, x);
			matRawData.set(1, 0, y);
			matRawData.set(2, 0, z);
			//matRawData.timesEquals(1.0/matRawData.normF()); //normalize

			Matrix t = matRawData.minus(matEllipsoidCenter);
			matCompensateData = matEllipsoidTransform.times(t);
			//matCompensateData.timesEquals(1.0/matCompensateData.normF()); //normalize
			
			double[][] array = { {Math.cos(pitch),0.0,Math.sin(pitch)},
					{Math.sin(roll)*Math.sin(pitch),Math.cos(roll),-Math.sin(roll)*Math.cos(pitch)},
					{Math.cos(roll)*Math.sin(pitch),Math.sin(roll),Math.cos(roll)*Math.cos(pitch) } }; 
			Matrix matM = new Matrix(array);
			
			matTiltCompensatedData = matM.times(matCompensateData);

			//double mx2 = x*Math.cos(pitch)+z*Math.sin(pitch);
			//double my2 = x*Math.sin(roll)*Math.sin(pitch)+y*Math.cos(roll)-z*Math.sin(roll)*Math.cos(pitch);
			//double mz2 = -x*Math.cos(roll)*Math.sin(pitch)+y*Math.sin(roll)+z*Math.cos(roll)*Math.cos(pitch);
			
			
			double mx2 = matTiltCompensatedData.get(0, 0);
			double my2 = matTiltCompensatedData.get(1, 0);
			//double mz2 = matTiltCompensatedData.get(2, 0);
			heading = (float)Math.atan2(my2,mx2);
			
		}

	}
}

