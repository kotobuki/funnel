package processing.funnel;

/**
 * @author endo
 * @version 1.0
 * 
 */
public class PinEvent {
	public IOModule.Pin target;
	
	public PinEvent (IOModule.Pin target){
		this.target = target;
	}
}
