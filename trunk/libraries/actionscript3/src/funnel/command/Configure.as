package funnel.command
{
	import funnel.osc.*;

	public class Configure extends OSCMessage
	{
		public function Configure(configuration:Array):void {
			super("/configure");
			for each (var portType:uint in configuration) 
				addValue(new OSCInt(portType));
		}
	}
}