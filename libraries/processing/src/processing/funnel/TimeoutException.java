package processing.funnel;

/**
 * @author endo
 * @version 1.0
 * 
 */
public class TimeoutException extends Exception{

	private static final long serialVersionUID = 1585802297283094183L;

	public TimeoutException(){}
	public TimeoutException(String message){
		super(message);
	}
}
