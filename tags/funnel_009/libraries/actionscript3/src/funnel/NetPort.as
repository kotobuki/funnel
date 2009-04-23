package funnel
{
	import flash.net.Socket;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;

	/**
	 * Socketのラッパーです。ソケットの接続処理をTaskとして管理します。
	 * @private
	 * 
	 */ 
	public class NetPort extends EventDispatcher
	{
		protected var _socket:Socket;
		
		public function NetPort() {
			_socket = new Socket();
		}
		
		public function connect(host:String, port:Number):Task {
			var task:Task = Task.waitEvent(
				_socket,
				Event.CONNECT,
				IOErrorEvent.IO_ERROR,
				SecurityErrorEvent.SECURITY_ERROR
			);
			_socket.connect(host, port);
			return task;
		}
	}
}