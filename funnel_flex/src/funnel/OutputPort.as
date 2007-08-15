package funnel
{
	public class OutputPort extends Port
	{
		internal var onUpdate:Function;
		
		public function OutputPort()
		{
			super();
			onUpdate = function():void {
				;
			}
		}
		
		override public function get direction():uint {
			return PortDirection.OUTPUT;
		}
		
		override public function set value(val:Number):void {
			_value = val;
			onUpdate(_value);
		}
		
	}
}