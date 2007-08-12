package funnel
{
	public class Din extends Port
	{
		public function Din(funnel:Funnel, server:Server, portNum:uint) {
			super(funnel, server, portNum);
		}
		
		override public function get direction():uint {
			return PortDirection.INPUT;
		}
		
		override public function get type():uint {
			return PortType.DIGITAL;
		}
	}
}