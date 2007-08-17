package funnel
{
	import flash.utils.ByteArray;
	import flash.events.*;
	import flash.net.Socket;
	import funnel.async.Deferred;
	import funnel.error.*;
	import funnel.osc.*;
	
	public class NotificationPort extends EventDispatcher
	{
		private var _inputPacket:OSCPacket;
		
		private var _socket:Socket;
		
		public function NotificationPort() {
			_socket = new Socket();
		}
		
		public function get inputPacket():OSCPacket {
			return _inputPacket;
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
			for (var i:uint = 0; i < bundles.length; ++i) {
				_inputPacket = OSCPacket.createWithBytes(bundles[i]);
				dispatchEvent(new Event(Event.CHANGE));
			}
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
		
	}
}