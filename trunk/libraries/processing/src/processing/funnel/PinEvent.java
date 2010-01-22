package processing.funnel;

/**
 * @author endo
 * @version 1.0
 * 
 */
public class PinEvent {
	public IOModule.ModulePin target;
	
	public PinEvent (IOModule.ModulePin target){
		this.target = target;
	}
}
