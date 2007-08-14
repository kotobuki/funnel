package funnel
{
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.events.*;
	import flash.utils.Timer;
	import funnel.async.Deferred;
	import funnel.osc.*;
	import funnel.error.*;
	
	public class CommandPort
	{
		private static const NO_ERROR:uint = 0;
		private static const SERVER_ERRORS:Array = [
			,
			CommunicationError,
			RebootError,
			ConfigurationError];
		
		private var _socket:Socket;
		private var _sendAndWait:Function;

		public function CommandPort() {
			_socket = new Socket();
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
		
		public function connect(host:String, port:Number):Deferred {
			return Deferred.createDeferredFunctionWithEvent(
				_socket, 
				_socket.connect, 
				[Event.CONNECT],
				[IOErrorEvent.IO_ERROR, SecurityErrorEvent.SECURITY_ERROR]
			)(host, port).addErrback(
				null,
				function():void {
					throw new ServerNotFoundError();
				}
			);
		}
		
		public function writeCommand(command:OSCMessage):Deferred {
			return _sendAndWait(command.toBytes()).addCallback(this, checkError);
		}
		
		private function checkError():void {
			var response:ByteArray = new ByteArray();
			_socket.readBytes(response);
			var errorCode:uint = OSCPacket.createWithBytes(response).value[0];
			if (errorCode != NO_ERROR)
				throw new SERVER_ERRORS[errorCode];
		}
	}
}