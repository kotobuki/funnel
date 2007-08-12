package funnel.osc
{
	import flash.utils.*;
	import funnel.osc.*;
	
	public class OSCPacket
	{		
		private static const _NUMBERSIGN:int = 35;
		
		protected var _address:OSCString;
		protected var _values:Array;
		
		public function OSCPacket(address:String) {
			_address = new OSCString(address);
			_values = new Array();
		}
		
		public function get address():String {
			return _address.value;
		}
		
		public function get value():Array {
			return _values;
		}
		
		public function toBytes():ByteArray {
			var bytes:ByteArray = new ByteArray();
			writeAddress(bytes);
			writeTag(bytes);
			writeBody(bytes);
			return bytes;
		}
		
		public function writeAddress(bytes:ByteArray):void {
			_address.writeToBytes(bytes);
		}
		
		public function writeTag(bytes:ByteArray):void {
			
		}
		
		public function writeBody(bytes:ByteArray):void {
			
		}
		
		public static function createWithBytes(bytes:ByteArray, end:int = -1):OSCPacket {
			if (end == -1)
			    end = bytes.length;
			
			if (bytes[bytes.position] == _NUMBERSIGN)
			    return OSCBundle.createWithBytes(bytes, end);
			else
			    return OSCMessage.createWithBytes(bytes);
		}
	}
}