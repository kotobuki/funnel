package funnel
{
	public class OutputPort extends Port
	{
		private var _exportMethod:Function;
		
		public function OutputPort(portNum:uint, exportMethod:Function)
		{
			super(portNum);
			_exportMethod = exportMethod;
		}
		
		override public function get direction():uint {
			return PortDirection.OUTPUT;
		}
		
		override public function set value(val:Number):void {
			_value = val;
			update();
		}
		
		override public function update():void {
			_exportMethod(_portNum, _value);
		}
		
	}
}