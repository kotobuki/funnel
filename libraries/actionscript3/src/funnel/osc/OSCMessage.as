package funnel.osc
{
	import flash.utils.*;
	
	/**
	 * 
	 * @private
	 * 
	 */ 
	public class OSCMessage extends OSCPacket
	{	
		public function OSCMessage(address:String, ...args) {
			super(address);
			for each (var arg:* in args)
				if (arg is OSCType)
					addValue(arg);
		}
		
		public function addValue(value:OSCType):void {
			_values.push(value);
		}

		override protected function writeTag(bytes:ByteArray):void {
			new OSCString(getTypeStr()).writeToBytes(bytes);
		}
		
		private function getTypeStr():String {
			var typeStr:String = ",";
			for each (var o:OSCType in _values)
				typeStr += o.type;
			return typeStr;
		}
		
		override protected function writeBody(bytes:ByteArray):void {
			for each (var o:OSCType in _values)
				o.writeToBytes(bytes);
		}
		
		internal static function createWithBytes(bytes:ByteArray):OSCMessage {
			var msg:OSCMessage = new OSCMessage(OSCString.createWithBytes(bytes).value);
			var typeStr:String = OSCString.createWithBytes(bytes).value.slice(1);
			for (var i:uint = 0; i < typeStr.length; ++i) 
				msg.addValue(OSCType.createWithBytes(typeStr.charAt(i), bytes));
			return msg;
		}

	}
}