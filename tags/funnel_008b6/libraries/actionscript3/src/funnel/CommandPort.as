package funnel
{
	import flash.events.*;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import funnel.osc.*;
	
	/**
	 * FunnelServerのコマンドポートと通信を行うクラスです。
	 * @private
	 */ 
	public class CommandPort extends NetPort
	{
		private static const ERROR_EVENTS:Array = [
			null,
			FunnelErrorEvent.ERROR,
			FunnelErrorEvent.REBOOT_ERROR,
			FunnelErrorEvent.CONFIGURATION_ERROR];
			
		private var _inputMessage:OSCMessage;
		private var _task:Task;

		public function CommandPort() {
			super();
			_socket.addEventListener(ProgressEvent.SOCKET_DATA, handleSocketData);
		}
		
		public function get inputMessage():OSCMessage {
			return _inputMessage;
		}

		public function writeCommand(command:OSCMessage):Task {
			_task = new Task();
			_socket.writeBytes(prependLength(command.toBytes()));
			_socket.flush();
			return _task;
		}
		
		private function prependLength(bytes:ByteArray):ByteArray {
			var result:ByteArray = new ByteArray();
			result.endian = Endian.BIG_ENDIAN;
			result.writeUnsignedInt(bytes.length);
			result.writeBytes(bytes);
			return result;
		}
		
		private function handleSocketData(e:ProgressEvent):void {
			var response:ByteArray = new ByteArray();
			response.endian = Endian.BIG_ENDIAN;
			_socket.readBytes(response);

			while (response.bytesAvailable > 0) {
				var packetSize:uint = response.readUnsignedInt();
				var packet:ByteArray = new ByteArray();
				response.readBytes(packet, 0, packetSize);
				var messages:Array = toMessages(OSCPacket.createWithBytes(packet));
				for each (_inputMessage in messages) {
					switch (_inputMessage.address) {
						case "/in":
							dispatchEvent(new Event(Event.CHANGE));
							break;
						case "/node":
							break;
						default:
							checkError();
					}
				}
			}
		}
		
		private function checkError():void {
			var args:Array = _inputMessage.value;
			if (args[0] is OSCInt && args[0].value < 0) {
				var errorCode:uint = -args[0].value;
				var message:String = '';
				if (args[1] != null) message = args[1].value;
				_task.fail(new FunnelErrorEvent(ERROR_EVENTS[errorCode], false, false, message));
			} else {
				_task.complete();
			}
		}
		
		private function toMessages(packet:OSCPacket):Array {
			if (packet is OSCBundle) return packet.value;
			else return [packet];
		}
	}
}