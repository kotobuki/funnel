package funnel
{
	import flash.net.Socket;
	import flash.events.*;
	import flash.utils.ByteArray;
	import funnel.osc.*;
	import funnel.command.*;

	public class Funnel extends EventDispatcher
	{
		public var autoUpadate:Boolean;
		public var samplingInterval:int;
		public var serviceInterval:int;
		public var port:Array;
		
		private var _commandPort:CommandPort;
		private var _notificationPort:Socket;

		public function Funnel(configuration:Array, host:String = "localhost", port:Number = 9000, samplingInterval:int = 33, serviceInterval:int = 20) {
			super();
			
			_commandPort = new CommandPort(host, port);
			_notificationPort = new Socket(host, port+1);
			_notificationPort.addEventListener(ProgressEvent.SOCKET_DATA, parseNotificationPortValue);
			
			initPortsWithConfiguration(configuration);
			autoUpadate = true;
			
			initIOModule(configuration, samplingInterval);
		}

		private function parseNotificationPortValue(event:Event):void {
			var response:ByteArray = new ByteArray();
			_notificationPort.readBytes(response);
			var bundles:Array = splitBundles(response);
			for (var i:uint = 0; i < bundles.length; ++i) 
				parseBundleBytes(bundles[i]);
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
		
		private function parseBundleBytes(bundleBytes:ByteArray):void {
			var messages:Array = OSCPacket.createWithBytes(bundleBytes).value;
			for (var i:uint = 0; i < messages.length; ++i) {
				var inputs:Array = messages[i].value;
				var startPortNum:uint = inputs[0].value;
				for (var j:uint = 0; j < inputs.length - 1; ++j) {
					port[startPortNum + j].value = inputs[j + 1].value;
					//trace(port[0].value);
				}
			}
		}
	
		private function initPortsWithConfiguration(configuration:Array):void {
			port = new Array();
			for (var i:uint = 0; i < configuration.length; ++i) {
				var aPort:Port = Port.createWithType(configuration[i], this, _commandPort, i);
				port.push(aPort);
			}
		}

		private function initIOModule(configuration:Array, samplingInterval:uint):void {
		    _commandPort.writeCommand(new Reset());
			_commandPort.writeCommand(new Configure(configuration));
			_commandPort.writeCommand(new SamplingInterval(samplingInterval));
			_commandPort.writeCommand(new Polling(true));
			_commandPort.callback();
			_commandPort.addErrback(null, trace);
		}

	}
}