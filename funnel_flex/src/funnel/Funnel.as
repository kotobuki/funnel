package funnel
{
	import flash.net.Socket;
	import flash.events.*;
	import flash.utils.ByteArray;
	import funnel.osc.*;

	public class Funnel extends EventDispatcher
	{
		public var autoUpadate:Boolean;
		public var samplingInterval:int;
		public var serviceInterval:int;
		public var port:Array;
		
		private var _server:Server;
		private var _notificationPort:Socket;

		public function Funnel(configuration:Array, host:String = "localhost", port:Number = 9000, samplingInterval:int = 8, serviceInterval:int = 20) {
			super();
			
			_server = new Server(host, port);
			_notificationPort = new Socket(host, port+1);
			_notificationPort.addEventListener(ProgressEvent.SOCKET_DATA, parseNotificationPortValue);
			
			initPortsWithConfiguration(configuration);
			autoUpadate = true;
			
			initIOModule(configuration, samplingInterval);
		}

		private function parseNotificationPortValue(event:Event):void {
			var response:ByteArray = new ByteArray();
			_notificationPort.readBytes(response);
			var inputs:Array = OSCPacket.createWithBytes(response).value;
			var startPortNum:uint = inputs[0].value;
			for (var i:uint = 0; i < inputs.length - 1; ++i) {
				port[startPortNum + i].value = inputs[i + 1].value;
			}
		}
	
		private function initPortsWithConfiguration(config:Array):void {
			port = new Array();
			for (var i:uint = 0; i < config.length; ++i) {
				var aPort:Port = Port.createWithType(config[i], this, _server, i);
				port.push(aPort);
			}
		}

		private function initIOModule(configuration:Array, samplingInterval:uint):void {
		    _server.reset();
			_server.setConfiguration(configuration);
			_server.setSamplingInterval(samplingInterval);
			_server.startPolling();
			_server.callback();
			_server.addErrback(null, trace);
		}

	}
}