package funnel.osc
{
	import flash.utils.ByteArray;
	
	public class Debug
	{
		public static function traceBytes(bytes:ByteArray):void {
			var output:String = "";
			for (var i:uint = 0; i < bytes.length; ++i) {
				var byte:int = bytes[i];
				var s:String = String.fromCharCode(byte.toString());
				if ("#/,abcdefghijklmnopqrstuvwzABCDEFGHIJKLMNOPQRSTUVWZ".indexOf(s) == -1) s = "";
				if (s == "#") 
					output += "\n";
				else if (s == "/") 
					output += "\n    ";
				output += byte + "(" + s + ") ";
			}
			trace(output);
		}
	}
}