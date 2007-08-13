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
		
		protected var _funnel:Funnel;
		protected var _commandPort:CommandPort;
		protected var _portNum:uint;
		protected var _value:Number;
		
		public function Port(funnel:Funnel, commandPort:CommandPort, portNum:uint) {
			edgeDetection = true;
		    _funnel = funnel;
			_commandPort = commandPort;
			_portNum = portNum;
			_value = 0;
		}
		
		internal static function createWithType(type:uint, funnel:Funnel, commandPort:CommandPort, portNum:uint):Port {
			switch(type) {
				case AIN: return new AnalogInput(funnel, commandPort, portNum);
				case DIN: return new DigitalInput(funnel, commandPort, portNum);
				case AOUT: return new AnalogOutput(funnel, commandPort, portNum);
				case DOUT: return new DigitalOutput(funnel, commandPort, portNum);
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
			_commandPort.writeCommand(new Out(_portNum, _value));
		}
		
		protected function detectEdge(val:Number):void {
			if (!edgeDetection) 
				return;
			
			if (_value == 0 && val != 0 && onRisingEdge != null) {
				//trace(_value, val, _portNum);
				onRisingEdge();
			} else if (_value != 0 && val == 0 && onFallingEdge != null) {
				onFallingEdge();
			}
		}
	}
}