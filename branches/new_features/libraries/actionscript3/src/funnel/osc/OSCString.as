package funnel.osc
{
	import flash.utils.ByteArray;
	
	/**
	 * 
	 * @private
	 * 
	 */ 
	public class OSCString extends OSCType
	{
		private static const ENCODING:String = "ascii";
		
		public function OSCString(value:*) {
			super(value);
		}
		
		override public function get type():String {
			return OSCType.STRING;
		}

		override public function writeToBytes(bytes:ByteArray):void {
			bytes.writeMultiByte(_value, ENCODING);
			padZero(bytes);
		}
		
		public static function createWithBytes(bytes:ByteArray):OSCString {
			var count:uint = 0;
			var start:uint = bytes.position;
			for (var i:uint = start; bytes[i] != 0; i++, count++) {
                
            }
			var str:String = bytes.readUTFBytes(count);
			bytes.position = start + Math.floor((count + 4) / 4) * 4;
			return new OSCString(str);
		}	

		private static function padZero(bytes:ByteArray):void {
			var numOfZero:int = 4 - (bytes.length % 4);
			for (var i:uint = 0; i < numOfZero; ++i)
				bytes.writeByte(0);
		}
		
	}
}