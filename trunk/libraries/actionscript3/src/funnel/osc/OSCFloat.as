package funnel.osc
{
	import flash.utils.ByteArray;
	
	/**
	 * 
	 * @private
	 * 
	 */ 
	public class OSCFloat extends OSCType
	{
		public function OSCFloat(value:*) {
			super(value);
		}
		
		override public function get type():String {
			return OSCType.FLOAT;
		}

		override public function writeToBytes(bytes:ByteArray):void {
			bytes.writeFloat(_value);
		}
		
		public static function createWithBytes(bytes:ByteArray):OSCFloat {
			return new OSCFloat(bytes.readFloat());
		}	
	}
}