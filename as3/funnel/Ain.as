package funnel
{
	public class Ain extends Port
	{
		public function Ain(funnel:Funnel, server:Server, portNum:uint) {
			super(funnel, server, portNum);
		}
		
		override public function get direction():uint {
			return 0;
		}
		
		override public function get type():uint {
			return 0;
		}
	}
}