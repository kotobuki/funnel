package funnel.osc
{
	import flash.utils.ByteArray;
	
	/**
	 * 
	 * @private
	 * 
	 */ 
	public class OSCType
	{
		public static const FLOAT:String = "f";
		public static const INT:String = "i";
		public static const STRING:String = "s";
		
		protected var _value:*;
		
		public function OSCType(value:*) {
			_value = value;
		}
		
		public function get value():* {
			return _value;
		}
		
		public function get type():String {
			return null;
		}
		
		public function writeToBytes(bytes:ByteArray):void {}
		
		public static function createWithBytes(type:String, bytes:ByteArray):OSCType {
			switch(type) {
				case FLOAT: return OSCFloat.createWithBytes(bytes);
				case INT: return OSCInt.createWithBytes(bytes);
				case STRING: return OSCString.createWithBytes(bytes);
				default: throw new Error("Type code is illegal...");
			}
		}
		
		public function toString():String {
			return value.toString();
		}
		
	}
}