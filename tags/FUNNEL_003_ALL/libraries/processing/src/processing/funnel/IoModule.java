package processing.funnel;

public interface IoModule {

	public static final int PORT_AIN = 0;
	public static final int PORT_DIN = 1;
	public static final int PORT_AOUT = 2;
	public static final int PORT_DOUT = 3;

	public static final int IN = PORT_DIN;
	public static final int OUT = PORT_DOUT;
	public static final int PWM = PORT_AOUT;
	
	//出力ポートのはじめの番号と数を返す
	abstract int[] getOutputPortNumber();
	abstract int[] initialize(int[] config);
}
