package funnel
{
	import flash.errors.IllegalOperationError;
	import funnel.command.Out;
	
	public class Port
	{
		public static const AIN:uint = 0;
		public static const DIN:uint = 1;
		public static const AOUT:uint = 2;
		public static const DOUT:uint = 3;
		
		public var average:Number;
		public var minimum:Number;
		public var maximum:Number;
		public var edgeDetection:Boolean;
		public var onRisingEdge:Function;
		public var onFallingEdge:Function;
		
		protected var _portNum:uint;
		protected var _value:Number;
		
		public function Port(portNum:uint) {
			edgeDetection = true;
			_portNum = portNum;
			_value = 0;
		}
		
		internal static function createWithType(type:uint, exportMethod:Function, portNum:uint):Port {
			switch(type) {
				case AIN: return new AnalogInput(portNum);
				case DIN: return new DigitalInput(portNum);
				case AOUT: return new AnalogOutput(portNum, exportMethod);
				case DOUT: return new DigitalOutput(portNum, exportMethod);
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
		
		public function set value(val:Number):void {}
		
		public function update():void {}
		
		
	}
}