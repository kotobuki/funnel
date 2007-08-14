package funnel
{
	import flash.utils.ByteArray;
	import flash.events.*;
	import flash.net.Socket;
	import funnel.async.Deferred;
	import funnel.error.*;
	import funnel.osc.*;
	
	public class NotificationPort
	{
		private var _socket:Socket;
		private var _ioPorts:Array;
		
		public function NotificationPort(ports:Array) {
			_socket = new Socket();
			_ioPorts = ports;
		}
		
		public function connect(host:String, port:Number):Deferred {
			_socket.addEventListener(ProgressEvent.SOCKET_DATA, parseNotificationPortValue);
			return Deferred.createDeferredFunctionWithEvent(
				_socket, 
				_socket.connect, 
				[Event.CONNECT],
				[IOErrorEvent.IO_ERROR, SecurityErrorEvent.SECURITY_ERROR]
			)(host, port).addErrback(
				null,
				function():void {
					throw new NotificationPortNotFoundError();
				}
			);
		}
		
		private function parseNotificationPortValue(event:Event):void {
			var response:ByteArray = new ByteArray();
			_socket.readBytes(response);
			var bundles:Array = splitBundles(response);
			for (var i:uint = 0; i < bundles.length; ++i) 
				parseBundleBytes(bundles[i]);
		}
		
		private static function splitBundles(bytes:ByteArray):Array {
			var bundles:Array = new Array();
			var offset:uint = 0;
			for (var i:uint = 0; i < bytes.length; ++i) {
				if (bytes[i+1] == null || OSCBundle.isBundle(bytes, i+1)) {
					var bundleBytes:ByteArray = new ByteArray();
					bytes.readBytes(bundleBytes, 0, i - offset + 1);
					bundles.push(bundleBytes);
					offset = i+1;
				}
			}
			return bundles;
		}
		
		private function parseBundleBytes(bundleBytes:ByteArray):void {
			var messages:Array = OSCPacket.createWithBytes(bundleBytes).value;
			for (var i:uint = 0; i < messages.length; ++i) {
				var portValues:Array = messages[i].value;
				var startPortNum:uint = portValues[0].value;
				for (var j:uint = 0; j < portValues.length - 1; ++j) {
					_ioPorts[startPortNum + j].setInputValue(portValues[j + 1].value);
				}
			}
		}
		
	}
}