/*
FunnelはFunnel開発チームによって開発され、修正版BSDライセンスの元で配布されています。

謝辞：
Funnel v1.0は未踏ソフトウェア創造事業2007年度第I期の支援を受けて開発されました。
*/

package funnel
{
	import flash.net.Socket;
	import funnel.command.*;
	import funnel.async.*;

	public class Funnel
	{
		public var autoUpdate:Boolean;
		public var onReady:Function;
		public var onFatalError:Function;
		public var portCount:uint;
		
		private var _ioPorts:Array;
		private var _d:Deferred;
		private var _samplingInterval:int;
		private var _commandPort:CommandPort;
		private var _notificationPort:NotificationPort;

		public function Funnel(configuration:Array, host:String = "localhost", portNum:Number = 9000, samplingInterval:int = 33) {
			autoUpdate = true;
			initPortsWithConfiguration(configuration);
			connectServerAndInitIOModule(host, portNum, configuration, samplingInterval);
		}
		
		public function port(portNum:uint):Port {
			return Port(_ioPorts[portNum]);
		}
		
		public function get samplingInterval():int {
			return _samplingInterval;
		}
		
		public function set samplingInterval(val:int):void {
			_samplingInterval = val;
			_d.addCallback(_commandPort, _commandPort.writeCommand, new SamplingInterval(val));
		}
		
		public function update():void {
			for (var i:uint = 0; i < _ioPorts.length; ++i) {
				var aPort:Port = _ioPorts[i];
				if (aPort is OutputPort) exportValue(i, aPort.value);
			}
		}
		
		private function exportValue(portNum:uint, portValue:Number):void {
			_d.addCallback(_commandPort, _commandPort.writeCommand, new Out(portNum, portValue));
		}
		
		private function callReadyHandler():void {
			if (onReady != null) onReady();
		}
		
		private function callErrorHandler(e:Error):void {
			trace(e);
			if (onFatalError != null) onFatalError(e);
		}
	
		private function initPortsWithConfiguration(configuration:Array):void {
			_ioPorts = new Array();
			for (var i:uint = 0; i < configuration.length; ++i) {
				var aPort:Port = Port.createWithType(configuration[i]);
				if (aPort is OutputPort) {
					OutputPort(aPort).onUpdate = function(id:uint):Function {
						return function(portValue:Number):void {
							if (autoUpdate) exportValue(id, portValue);
						};
					}(i);
				}
				_ioPorts.push(aPort);
			}
			portCount = _ioPorts.length;
		}

		private function connectServerAndInitIOModule(host:String, portNum:Number, configuration:Array, samplingInterval:uint):void {
			_commandPort = new CommandPort();
			_notificationPort = new NotificationPort(_ioPorts);
			
			_d = new Deferred();
			_d.addCallback(_commandPort, _commandPort.connect, host, portNum);//throw ServerNotFoundError
			_d.addCallback(_commandPort, _commandPort.writeCommand, new Reset());//throw RebootError
			_d.addCallback(_commandPort, _commandPort.writeCommand, new Configure(configuration));//throw ConfigurationError
			this.samplingInterval = samplingInterval;
			_d.addCallback(_commandPort, _commandPort.writeCommand, new Polling(true));
			_d.addCallback(_notificationPort, _notificationPort.connect, host, portNum+1);//throw NotificatonPortNotFoundError
			
			_d.addCallback(this, callReadyHandler);
			_d.addErrback(this, callErrorHandler);
			_d.callback();
		}
		
	}
}