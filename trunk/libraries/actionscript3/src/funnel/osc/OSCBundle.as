package funnel.osc
{
	import flash.utils.ByteArray;
	
	/**
	 * 
	 * @private
	 * 
	 */ 
	public class OSCBundle extends OSCPacket
	{
		private static const BUNDLE:String = "#bundle";
		private static const SHARP:int = 35;
		
		public function OSCBundle() {
			super(BUNDLE);
		}
		
		//TODO:とりあえず0にしておくが
		override protected function writeTag(bytes:ByteArray):void {
			for (var i:uint = 0; i < 8; ++i)
				bytes.writeByte(0);
		}
		
		override protected function writeBody(bytes:ByteArray):void {
			for each (var o:OSCPacket in _values) {
				var data:ByteArray = o.toBytes();
				bytes.writeInt(data.length);
				bytes.writeBytes(data);
			}
		}
		
		internal static function createWithBytes(bytes:ByteArray, end:int):OSCBundle {
			var bundle:OSCBundle = new OSCBundle();
			if (OSCString.createWithBytes(bytes).value != BUNDLE)
				return null;
			bytes.position += 8; //TODO: readLongしてtimeに格納すべき
			while (bytes.position < end) {
				var packet:OSCPacket = OSCPacket.createWithBytes(bytes, OSCInt.createWithBytes(bytes).value);
				bundle.addValue(packet);
			}
			return bundle;
		}
		
		public function addValue(value:OSCPacket):void {
			_values.push(value);
		}
		
		public static function isBundle(bytes:ByteArray, start:int):Boolean {
			if (bytes[start] != SHARP) return false;
			
			var oldPosition:int = bytes.position;
			bytes.position = start;
			var str:String = OSCString.createWithBytes(bytes).value;
			bytes.position = oldPosition;
			
			return (str == BUNDLE);
		}
		
	}
}