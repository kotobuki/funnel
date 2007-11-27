package funnel
{
	import flash.utils.ByteArray;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.net.Socket;
	import funnel.osc.OSCBundle;
	import funnel.osc.OSCPacket;
	
	/**
	 * FunnelServerの通知ポートからのメッセージをパースするクラスです。
	 * @private
	 */	
	public class NotificationPort extends NetPort
	{
		private var _inputPacket:OSCPacket;
		
		public function NotificationPort() {
			super();
			_socket.addEventListener(ProgressEvent.SOCKET_DATA, parseNotificationPortValue);
		}
		
		public function get inputPacket():OSCPacket {
			return _inputPacket;
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