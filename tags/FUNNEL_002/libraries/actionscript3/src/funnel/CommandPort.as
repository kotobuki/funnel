package funnel
{
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.events.*;
	import flash.utils.Timer;
	import funnel.osc.*;
	import funnel.event.FunnelErrorEvent;
	import funnel.async.*;
	
	public class CommandPort extends NetPort
	{
		private static const NO_ERROR:uint = 0;
		private static const ERROR_EVENTS:Array = [
			,
			FunnelErrorEvent.FATAL_ERROR,
			FunnelErrorEvent.REBOOT_ERROR,
			FunnelErrorEvent.CONFIGURATION_ERROR];

		public function CommandPort() {
			super();
		}

		public function writeCommand(command:OSCMessage):Task {
			var task:Task = new Task();
			waitEvent(_socket, ProgressEvent.SOCKET_DATA).completed = cmd(checkError, task);
			_socket.writeBytes(command.toBytes());
			_socket.flush();
			return task;
		}
		
		private function checkError(task:Task):void {
			var response:ByteArray = new ByteArray();
			_socket.readBytes(response);
			var args:Array = OSCPacket.createWithBytes(response).value;
			if (args[0] is OSCInt && args[0].value < 0) {
				var errorCode:uint = -args[0].value;
				var message:String = '';
				if (args[1] != null) message = args[1].value;
				task.fail(new FunnelErrorEvent(ERROR_EVENTS[errorCode], false, false, message));
			} else {
				task.complete();
			}
		}
	}
}