package processing.funnel;

public interface IoModule {

	public static final int PORT_AIN = 0;
	public static final int PORT_DIN = 1;
	public static final int PORT_AOUT = 2;
	public static final int PORT_DOUT = 3;

	abstract int[] getOutputPortNumber();
	abstract void initialize(int[] config);
}
