package funnel
{
	import flash.events.Event;
	import funnel.osc.*;

	public class IOModule
	{
		private var _system:IOSystem;
		private var _id:uint;
		private var _ioPorts:Array;
		private var _updatedValues:Array;
		private var _portCount:uint;
		private var _config:Configuration;

		public function IOModule(system:IOSystem, id:uint, configuration:Configuration) {
			_system = system;
			_id = id;
			_config = configuration;
			
			var portTypes:Array = _config.config;
			_portCount = portTypes.length;
			_ioPorts = new Array(_portCount);
			_updatedValues = new Array(_portCount);
			for (var i:uint = 0; i < _portCount; ++i) {
				var aPort:Port = new Port(i, portTypes[i]);
				var type:uint = aPort.type;
				if (type == Port.AOUT || type == Port.DOUT) {
					aPort.addEventListener(PortEvent.CHANGE, handleChange);
				}
				_ioPorts[i] = aPort;
			}
		}
		
		public function port(portNum:uint):Port {
			return _ioPorts[portNum];
		}
		
		public function get portCount():uint {
			return _portCount;
		}
		
		private function handleChange(event:PortEvent):void {
			var port:Port = event.target as Port;
			var index:uint = port.number;
			if (_system.autoUpdate) {
				_system.sendOut(_id, index, [port.value]);
			} else {
				_updatedValues[index] = port.value;
			}
		}
		
		internal function update():void {
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
					_system.sendOut(_id, startIndex, adjoiningValues);
					adjoiningValues = null;
				}
			}
			if (adjoiningValues != null) {
				_system.sendOut(_id, startIndex, adjoiningValues);
			}
		}

	}
}