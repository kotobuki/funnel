package funnel
{
	public class Aout extends Port
	{	
		public function Aout(funnel:Funnel, server:Server, portNum:uint) {
			super(funnel, server, portNum);
		}
		
		override public function get direction():uint {
			return 1;
		}
		
		override public function get type():uint {
			return 0;
		}
		
		override public function set value(val:Number):void {
			_value = val;
			if (_funnel.autoUpadate) update();
		}
	}
}