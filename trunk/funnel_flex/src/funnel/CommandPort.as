package funnel
{
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.events.*;
	import flash.utils.Timer;
	import funnel.async.Deferred;
	import funnel.osc.*;
	import funnel.error.*;
	
	public class CommandPort extends Deferred
	{
		private static const NO_ERROR:uint = 0;
		private static const ERROR_MESSAGES:Array = [
			"NO_ERROR",
			"ERROR",
			"REBOOT_ERROR",
			"CONFIGURATION_ERROR"];
		
		private var _socket:Socket;
		private var _sendAndWait:Function;

		public function CommandPort(host:String, port:Number) {
			_socket = new Socket();
			_sendAndWait = Deferred.createDeferredFunctionWithEvent(
				_socket,
				_socket.writeBytes,
				[ProgressEvent.SOCKET_DATA]);
			connect(host, port);
		}
		
		public function delay(delay:Number):void {
		    var timer:Timer = new Timer(delay, 1);
			addCallback(
			    null,
			    Deferred.createDeferredFunctionWithEvent(
				    timer, 
				    timer.start, 
				    [TimerEvent.TIMER_COMPLETE], 
				    null, 
				    timer.stop));
		}
		
		public function writeCommand(command:OSCMessage):void {
		    addCallback(null, _sendAndWait, command.toBytes());
		    addCallback(this, checkError);
		}
		
		private function checkError():void {
			var response:ByteArray = new ByteArray();
			_socket.readBytes(response);
			var errorCode:uint = OSCPacket.createWithBytes(response).value[0];
			if (errorCode != NO_ERROR)
				throw new Error(ERROR_MESSAGES[errorCode]);
		}
		
		private function connect(host:String, port:Number):void {
			addCallback(
			    null, 
			    Deferred.createDeferredFunctionWithEvent(
				    _socket, 
				    _socket.connect, 
				    [Event.CONNECT],
					[IOErrorEvent.IO_ERROR, SecurityErrorEvent.SECURITY_ERROR]),
			    host,
			    port);
			
			
			addErrback(
				null,
				function():void {
					throw new ServerNotFoundError();
				});
		}
		
	}
}