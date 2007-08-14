package funnel
{
	public class DigitalOutput extends OutputPort
	{
		public function DigitalOutput(portNum:uint, exportMethod:Function) {
			super(portNum, exportMethod);
		}
		
		override public function get type():uint {
			return PortType.DIGITAL;
		}
		
		
	}
}