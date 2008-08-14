package funnel.osc
{
	import flash.utils.ByteArray;
	
	/**
	 * 
	 * @private
	 * 
	 */ 
	public class OSCInt extends OSCType
	{
		public function OSCInt(value:*) {
			super(value);
		}
		
		override public function get type():String {
			return OSCType.INT;
		}

		override public function writeToBytes(bytes:ByteArray):void {
			bytes.writeInt(_value);
		}
		
		public static function createWithBytes(bytes:ByteArray):OSCInt {
			return new OSCInt(bytes.readInt());
		} 
		
	}
}