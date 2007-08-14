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
		//public var serviceInterval:int;
		public var port:Array;
		public var onReady:Function;
		public var onFatalError:Function;
		
		private var _samplingInterval:int;
		private var _commandPort:CommandPort;
		private var _notificationPort:Socket;

		public function Funnel(configuration:Array, host:String = "localhost", port:Number = 9000, samplingInterval:int = 33) {
			super();

			_commandPort = new CommandPort(host, port);
			_notificationPort = new Socket(host, port+1);

			initPortsWithConfiguration(configuration);
			autoUpadate = true;
			
			initIOModule(configuration, samplingInterval);
		}
		
		public function get samplingInterval():int {
			return _samplingInterval;
		}
		
		public function set samplingInterval(val:int):void {
			_samplingInterval = val;
			_commandPort.writeCommand(new SamplingInterval(val));
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
				var portValues:Array = messages[i].value;
				var startPortNum:uint = portValues[0].value;
				for (var j:uint = 0; j < portValues.length - 1; ++j) {
					port[startPortNum + j].setInputValue(portValues[j + 1].value);
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
			
			_commandPort.addCallback(_notificationPort,
				_notificationPort.addEventListener,
				ProgressEvent.SOCKET_DATA, 
				parseNotificationPortValue);
			
			this.samplingInterval = samplingInterval;
			
			_commandPort.writeCommand(new Polling(true));
			
			_commandPort.addCallback(null, function():void {
				if (onReady != null)
					onReady();
			});
			_commandPort.addErrback(null, function(e:Error):void {
				if (onFatalError != null)
					onFatalError(e);
			});
			
			_commandPort.callback();
		}

	}
}