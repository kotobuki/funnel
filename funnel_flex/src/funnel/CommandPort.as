package funnel
{
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.events.*;
	import flash.utils.Timer;
	import funnel.async.Deferred;
	import funnel.osc.*;
	import funnel.error.*;
	import funnel.event.FunnelErrorEvent;
	
	public class CommandPort extends NetPort
	{
		private static const NO_ERROR:uint = 0;
		private static const ERROR_EVENTS:Array = [
			,
			FunnelErrorEvent.COMMUNICATION_ERROR,
			FunnelErrorEvent.REBOOT_ERROR,
			FunnelErrorEvent.CONFIGURATION_ERROR];
		
		private var _sendAndWait:Function;

		public function CommandPort() {
			super();
			_sendAndWait = Deferred.createDeferredFunctionWithEvent(
				_socket,
				_socket.writeBytes,
				[ProgressEvent.SOCKET_DATA]);
		}
		
		public function delay(delay:Number):Deferred {
			var timer:Timer = new Timer(delay, 1);
			return Deferred.createDeferredFunctionWithEvent(
				timer,
				timer.start,
				[TimerEvent.TIMER_COMPLETE],
				null,
				timer.stop)();
		}
		
		public function writeCommand(command:OSCMessage):Deferred {
			return _sendAndWait(command.toBytes()).addCallback(this, checkError);
		}
		
		private function checkError():void {
			var response:ByteArray = new ByteArray();
			_socket.readBytes(response);
			var packet:OSCPacket = OSCPacket.createWithBytes(response);
			if (packet.value[0] is Number && packet.value[0] < 0) {
				var errorCode:uint = -packet.value[0];
				var message:String = packet.value[1];
				throw new FunnelError(message, ERROR_EVENTS[errorCode]);
			}
		}
	}
}