/*
FunnelはFunnel開発チームによって開発され、修正版BSDライセンスの元で配布されています。

謝辞：
Funnel v1.0は未踏ソフトウェア創造事業2007年度第I期の支援を受けて開発されました。
*/

package funnel
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.Socket;
	import funnel.async.Task;
	import funnel.async.turn;
	import funnel.async.cmd;
	import funnel.command.*;;
	import funnel.event.FunnelEvent;
	import funnel.event.FunnelErrorEvent;
	import funnel.event.PortEvent;
	import funnel.ioport.Port;
	import funnel.osc.OSCPacket;
	import funnel.osc.OSCMessage;
	import funnel.osc.OSCFloat;

	public class Funnel extends EventDispatcher
	{
		public var autoUpdate:Boolean;
	
		private var _ioPorts:Array;
		private var _updatedValues:Array;
		private var _portCount:uint;
		private var _task:Task;
		private var _samplingInterval:int;
		private var _commandPort:CommandPort;
		private var _notificationPort:NotificationPort;
		private var _config:Object;

		public function Funnel(configuration:Object, host:String = "localhost", portNum:Number = 9000, samplingInterval:int = 33) {
			autoUpdate = true;
			_config = configuration;
			_samplingInterval = samplingInterval;
			initPortsWithConfiguration();
			connectServerAndInitIOModule(host, portNum);
		}
		
		public function port(portNum:uint):Port {
			return _ioPorts[portNum];
		}
		
		public function get portCount():uint {
			return _portCount;
		}
		
		public function analogInput(portNum:uint):Port {
			return _ioPorts[_config.ainPorts[portNum]];
		}
		
		public function digitalInput(portNum:uint):Port {
			return _ioPorts[_config.dinPorts[portNum]];
		}
		
		public function analogOutput(portNum:uint):Port {
			return _ioPorts[_config.aoutPorts[portNum]];
		}
		
		public function digitalOutput(portNum:uint):Port {
			return _ioPorts[_config.doutPorts[portNum]];
		}
		
		public function get button():Port {
			return _ioPorts[_config.button];
		}
		
		public function get led():Port {
			return _ioPorts[_config.led];
		}
		
		public function analogPin(portNum:uint):Port {
			return _ioPorts[_config.analogPins[portNum]];
		}
		
		public function digitalPin(portNum:uint):Port {
			return _ioPorts[_config.digitalPins[portNum]];
		}
		
		public function setDigitalPinMode(portNum:uint, mode:uint):void {
			_config.setDigitalPinMode(portNum, mode);
			_task.completed = cmd(_commandPort.writeCommand, new Configure(_config.config));
		}
		
		public function get samplingInterval():int {
			return _samplingInterval;
		}
		
		public function set samplingInterval(val:int):void {
			_samplingInterval = val;
			_task.completed = cmd(_commandPort.writeCommand, new SamplingInterval(val));
		}
		
		public function update():void {
			var value:Number;
			var adjoiningValues:Array;
			var startIndex:uint;
			for (var i:uint = 0; i < _portCount; ++i) {
				if (_updatedValues[i] != null) {
					if (adjoiningValues == null) {
						adjoiningValues = [];
						startIndex = i;
					}
					adjoiningValues.push(_updatedValues[i]);
					_updatedValues[i] = null;
				} else if (adjoiningValues != null) {
					exportValue(startIndex, adjoiningValues);
					adjoiningValues = null;
				}
			}
			if (adjoiningValues != null) {
				exportValue(startIndex, adjoiningValues);
			}
		}
		
		internal function exportValue(portNum:uint, portValues:Array):void {
			var message:OSCMessage = new Out(portNum);
			for (var i:uint = 0; i < portValues.length; ++i)
				message.addValue(new OSCFloat(portValues[i]));
			
			_task.completed = cmd(_commandPort.writeCommand, message);
		}
		
		private function onReceiveBundle(event:Event):void {
			var messages:Array = _notificationPort.inputPacket.value;
			for (var i:uint = 0; i < messages.length; ++i) {
				var portValues:Array = messages[i].value;
				var startPortNum:uint = portValues[0].value;
				for (var j:uint = 0; j < portValues.length - 1; ++j) {
					var aPort:Port = _ioPorts[startPortNum + j];
					var type:uint = aPort.type;
					if (type == Port.AIN || type == Port.DIN) 
						aPort.value = portValues[j + 1].value;
				}
			}
		}

		private function initPortsWithConfiguration():void {
			var configuration:Array = _config.config;
			_portCount = configuration.length;
			_ioPorts = new Array(_portCount);
			_updatedValues = new Array(_portCount);
			for (var i:uint = 0; i < _portCount; ++i) {
				var aPort:Port = new Port(i, configuration[i]);
				var type:uint = aPort.type;
				if (type == Port.AOUT || type == Port.DOUT)
					aPort.addEventListener(PortEvent.CHANGE, handleChange);
				_ioPorts[i] = aPort;
			}
		}
		
		private function handleChange(event:PortEvent):void {
			var port:Port = event.target as Port;
			var index:uint = port.number;
			if (autoUpdate)
				exportValue(index, [port.value]);
			else
				_updatedValues[index] = port.value;
		}

		private function connectServerAndInitIOModule(host:String, portNum:Number):void {
			_commandPort = new CommandPort();
			_notificationPort = new NotificationPort();
			_notificationPort.addEventListener(Event.CHANGE, onReceiveBundle);
			
			_task = turn (
				cmd (_commandPort.connect, host, portNum),
				cmd (_commandPort.writeCommand, new Reset()),
				cmd (_commandPort.writeCommand, new Configure(_config.config)),
				cmd (_commandPort.writeCommand, new SamplingInterval(_samplingInterval)),
				cmd (_commandPort.writeCommand, new Polling(true)),
				cmd (_notificationPort.connect, host, portNum+1),
				cmd (dispatchEvent, new FunnelEvent(FunnelEvent.READY))
			)();
			_task.failed = dispatchEvent;
		}
	}
}