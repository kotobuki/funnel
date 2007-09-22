package processing.funnel;

public class FunnelException extends Exception{
	/**
	 * 
	 */
	private static final long serialVersionUID = 3822162093813159142L;

	public int error;
	public FunnelException(){}
		
	public FunnelException(String message,int error){
		super(message);
		this.error = error;
	}
}
