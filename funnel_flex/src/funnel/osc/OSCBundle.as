package funnel.osc
{
	import flash.utils.ByteArray;
	
	public class OSCBundle extends OSCPacket
	{
		private static const _BUNDLE:String = "#bundle";
		
		public function OSCBundle() {
			super(_BUNDLE);
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
			if (OSCString.createWithBytes(bytes).value != _BUNDLE)
			    return null;
			bytes.position += 8; //TODO: readLongしてtimeに格納すべき
			while (bytes.position < end) 
				bundle.addValue(OSCPacket.createWithBytes(bytes, OSCInt.createWithBytes(bytes).value));
			
			return bundle;
		}
		
		public function addValue(value:OSCPacket):void {
			_values.push(value);
		}
		
	}
}