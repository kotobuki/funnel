package funnel
{
	import flash.errors.IllegalOperationError;
	
	public class Port
	{
		public static const AIN:uint = 0;
		public static const DIN:uint = 1;
		public static const AOUT:uint = 2;
		public static const DOUT:uint = 3;
		
		protected var _funnel:Funnel;
		protected var _server:Server;
		protected var _portNum:uint;
		protected var _value:Number;
		
		public function Port(funnel:Funnel, sender:Server, portNum:uint) {
		    _funnel = funnel;
			_server = sender;
			_portNum = portNum;
			_value = 0;
		}
		
		internal static function createWithType(type:uint, funnel:Funnel, server:Server, portNum:uint):Port {
			switch(type) {
				case AIN: return new Ain(funnel, server, portNum);
				case DIN: return new Din(funnel, server, portNum);
				case AOUT: return new Aout(funnel, server, portNum);
				case DOUT: return new Dout(funnel, server, portNum);
				default: throw new IllegalOperationError("タイプコードの値が不正");
			}
		}
		
		public function get direction():uint {
			return undefined;
		}
		
		public function get type():uint {
			return undefined;
		}
		
		public function get value():Number {
			return _value;
		}
		
		public function set value(val:Number):void {
		    _value = val;
		}
		
		public function update():void {
			_server.setPortValues(_portNum, _value);
		}
	}
}