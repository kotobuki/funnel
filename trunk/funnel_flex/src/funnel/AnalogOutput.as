package funnel
{
	public class AnalogOutput extends OutputPort
	{	
		public function AnalogOutput(portNum:uint, exportMethod:Function) {
			super(portNum, exportMethod);
		}
		
		override public function get type():uint {
			return PortType.ANALOG;
		}
	}
}