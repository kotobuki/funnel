package funnel.gui {
	import funnel.*;
	import funnel.osc.*;

	public interface IOnScreenCommandPort {
		function connect(host:String, port:Number):Task;
		function get inputMessage():OSCMessage;
		function writeCommand(command:OSCMessage):Task;
	}
}