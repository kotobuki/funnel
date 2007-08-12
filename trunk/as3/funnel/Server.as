package funnel
{
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.events.*;
	import flash.utils.Timer;
	import funnel.async.Deferred;
	import funnel.osc.*;
	
	public class Server extends Deferred
	{
		private var _socket:Socket;
		private var _sendAndWait:Function;

		public function Server(host:String, port:Number) {
			_socket = new Socket();
			_sendAndWait = Deferred.createDeferredFunctionWithEvent(
				_socket,
				_socket.writeBytes,
				[ProgressEvent.SOCKET_DATA]);
			connect(host, port);
		}
		
		private function sendMessage(msg:OSCMessage):void {
		    addCallback(null, _sendAndWait, msg.toBytes());
		    /*
			addCallback(this, function():Deferred {
				var d:Deferred = _sendAndWait(msg.toBytes());
				return d.addCallback(null, function():* {
					var response:ByteArray = new ByteArray();
					_socket.readBytes(response);
					var packet:OSCPacket = OSCPacket.createWithBytes(response);
					return packet.value;
				});
			});
			*/
		}
		
		private function connect(host:String, port:Number):void {
			addCallback(
			    null, 
			    Deferred.createDeferredFunctionWithEvent(
				    _socket, 
				    _socket.connect, 
				    [Event.CONNECT],
					[IOErrorEvent.IO_ERROR, SecurityErrorEvent.SECURITY_ERROR]
			    ),
			    host,
			    port
			);
		}
		
		public function quit():void {
			sendMessage(new OSCMessage("/quit"));
		}
		
		public function reset():void {
			sendMessage(new OSCMessage("/reset"));
		}
		
		public function setConfiguration(portTypes:Array):void {
			var msg:OSCMessage = new OSCMessage("/configure");
			for each(var portType:Number in portTypes) {
				msg.addValue(new OSCInt(portType));
			}
			sendMessage(msg);
		}
		
		public function startPolling():void {
			sendMessage(new OSCMessage("/polling", new OSCInt(1)));
		}
		
		public function stopPolling():void {
			sendMessage(new OSCMessage("/polling", new OSCInt(0)));
		}
		
		public function getPortValues(start:uint, count:uint):void {
			sendMessage(new OSCMessage("/in", new OSCInt(start), new OSCInt(count)));
		}
		
		public function setPortValues(start:uint, ...outValues):void {
			var msg:OSCMessage = new OSCMessage("/out", new OSCInt(start));
			for each(var outValue:Number in outValues) {
				msg.addValue(new OSCFloat(outValue));
			}
			sendMessage(msg);
		}
		
		public function setSamplingInterval(interval:uint):void {
		    sendMessage(new OSCMessage("/samplingInterval", new OSCInt(interval)));
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
				    timer.stop
				)
			);
		}
		
	}
}