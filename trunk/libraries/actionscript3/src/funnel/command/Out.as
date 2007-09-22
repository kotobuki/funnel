package funnel.command
{
	import funnel.osc.*;

	public class Out extends OSCMessage
	{
		public function Out(startPortNum:uint, ...outValues):void {
			super("/out", new OSCInt(startPortNum));
			for each (var outValue:Number in outValues) 
				addValue(new OSCFloat(outValue));
		}
	}
}