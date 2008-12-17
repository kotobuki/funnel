package processing.funnel;

/**
 * @author endo
 * @version 1.0
 * 
 */
public class PinEvent {
	public IOModule.Port target;
	
	public PinEvent (IOModule.Port target){
		this.target = target;
	}
}
