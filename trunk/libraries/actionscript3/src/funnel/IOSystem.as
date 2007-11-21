package funnel
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import funnel.osc.*;

	public class IOSystem extends EventDispatcher
	{
		public var autoUpdate:Boolean;
		private var _modules:Array;
		private var _commandPort:CommandPort;
		private var _notificationPort:NotificationPort;
		private var _samplingInterval:int;
		private var _task:Task;

		public function IOSystem(configs:Array, host:String = "localhost", portNum:Number = 9000, samplingInterval:int = 33) {
			autoUpdate = true;
			_modules = [];
			_commandPort = new CommandPort();
			_notificationPort = new NotificationPort();
			_notificationPort.addEventListener(Event.CHANGE, onReceiveBundle);
			
			_task = new Task().complete();
			_task.addCallback(_commandPort.connect, host, portNum);
			_task.addCallback(_notificationPort.connect, host, portNum+1);
			sendReset();
			for (var i:uint = 0; i < configs.length; ++i) {
				var config:Configuration = configs[i];
				_modules.push(new IOModule(this, i, config));
				sendConfiguration(i, config.config);
			}
			this.samplingInterval = samplingInterval;
			sendPolling(true);
			_task.addCallback(dispatchEvent, new FunnelEvent(FunnelEvent.READY));
			_task.addErrback(dispatchEvent);
		}
		
		public function module(moduleNum:uint):IOModule {
			return _modules[moduleNum];
		}
		
		public function get samplingInterval():int {
			return _samplingInterval;
		}
		
		public function set samplingInterval(val:int):void {
			_samplingInterval = val;
			sendSamplingInterval(val);
		}
		
		public function update():void {
			for each (var module:IOModule in _modules) {
				module.update();
			}
		}
		
		private function onReceiveBundle(event:Event):void {
			var messages:Array = _notificationPort.inputPacket.value;
			for (var i:uint = 0; i < messages.length; ++i) {
				var portValues:Array = messages[i].value;
				var module:IOModule = _modules[portValues[0].value];
				var startPortNum:uint = portValues[1].value;
				for (var j:uint = 0; j < portValues.length - 2; ++j) {
					var aPort:Port = module.port(startPortNum + j);
					var type:uint = aPort.type;
					if (type == Port.AIN || type == Port.DIN) {
						aPort.value = portValues[j + 2].value;
					}
				}
			}
		}

		private function sendReset():void {
			_task.addCallback(_commandPort.writeCommand, new OSCMessage("/reset"));
		}
		
		private function sendConfiguration(moduleNum:uint, config:Array):void {
			var msg:OSCMessage = new OSCMessage("/configure", new OSCInt(moduleNum));
			for each (var portType:uint in config) {
				msg.addValue(new OSCInt(portType));
			}
			_task.addCallback(_commandPort.writeCommand, msg);
		}
		
		private function sendSamplingInterval(interval:int):void {
			_task.addCallback(_commandPort.writeCommand, new OSCMessage("/samplingInterval", new OSCInt(interval)));
		}
		
		private function sendPolling(enabled:Boolean):void {
			_task.addCallback(_commandPort.writeCommand, new OSCMessage("/polling", new OSCInt(enabled ? 1 : 0)));
		}
		
		internal function sendOut(moduleNum:uint, portNum:uint, portValues:Array):void {
			var message:OSCMessage = new OSCMessage("/out", new OSCInt(moduleNum), new OSCInt(portNum));
			for (var i:uint = 0; i < portValues.length; ++i) {
				message.addValue(new OSCFloat(portValues[i]));
			}
			
			_task.addCallback(_commandPort.writeCommand, message);
		}
	}
}