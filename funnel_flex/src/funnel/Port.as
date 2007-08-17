package funnel
{
	import flash.errors.IllegalOperationError;
	import funnel.command.Out;
	import flash.events.EventDispatcher;
	
	public class Port extends EventDispatcher
	{
		public static const AIN:uint = 0;
		public static const DIN:uint = 1;
		public static const AOUT:uint = 2;
		public static const DOUT:uint = 3;
		
		protected var _value:Number;
		
		public function Port() {
			_value = 0;
		}
		
		internal static function createWithType(type:uint):Port {
			switch(type) {
				case AIN: return new AnalogInput();
				case DIN: return new DigitalInput();
				case AOUT: return new AnalogOutput();
				case DOUT: return new DigitalOutput();
				default: throw new IllegalOperationError("タイプコードの値が不正");
			}
		}
		
		public function get average():Number {
			return NaN;
		}
		
		public function get minimum():Number {
			return NaN;
		}
		
		public function get maximum():Number {
			return NaN;
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
		
		public function get filters():Array {
			return null;
		}
		
		public function set filters(array:Array):void {}
		
		public function clear():void {}
		
	}
}