package funnel
{
	import flash.events.EventDispatcher;
	import flash.net.Socket;
	import flash.events.*;
	import funnel.async.Deferred;
	import funnel.error.FunnelError;
	import funnel.event.FunnelErrorEvent;

	public class NetPort extends EventDispatcher
	{
		protected var _socket:Socket;
		
		public function NetPort() {
			_socket = new Socket();
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
					throw new FunnelError(
						"Funnel server was not found...",
						FunnelErrorEvent.SERVER_NOT_FOUND_ERROR
					);
				}
			);
		}
	}
}