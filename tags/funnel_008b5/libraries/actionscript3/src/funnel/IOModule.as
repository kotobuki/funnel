package funnel
{
	import flash.events.Event;
	import funnel.osc.*;

	/**
	 * PCに接続されたI/Oモジュールを抽象化して共通の方法でアクセスするためのクラスです。
	 *
	 */
	public class IOModule
	{
		private var _system:IOSystem;
		private var _id:uint;
		private var _ioPorts:Array;
		private var _updatedValues:Array;
		private var _portCount:uint;
		private var _config:Configuration;

		/**
		 *
		 * @param system FunnelServerと通信をするIOSystemオブジェクト
		 * @param id IOModuleオブジェクトのID
		 * @param configuration コンフィギュレーション
		 *
		 */
		public function IOModule(system:IOSystem, configuration:Configuration) {
			_system = system;
			_config = configuration;
			_id = configuration.moduleID;

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

		/**
		 * portNumで指定したPortオブジェクトを取得します。
		 * @param portNum ポート番号
		 * @return Portオブジェクト
		 * @see Port
		 */
		public function port(portNum:uint):Port {
			return _ioPorts[portNum];
		}

		/**
		 * pinNumで指定したアナログピンのPortオブジェクトを取得します。
		 * @param portNum アナログピン番号
		 * @return Portオブジェクト
		 * @see Port
		 */
		public function analogPin(pinNum:uint):Port {
			if (_config.analogPins == null) throw new ArgumentError("analog pins are not available");
			if (_config.analogPins[pinNum] == null) throw new ArgumentError("analog pin is not available at " + pinNum);
			return _ioPorts[_config.analogPins[pinNum]];
		}

		/**
		 * pinNumで指定したデジタルピンのPortオブジェクトを取得します。
		 * @param portNum デジタルピン番号
		 * @return Portオブジェクト
		 * @see Port
		 */
		public function digitalPin(pinNum:uint):Port {
			if (_config.digitalPins == null) throw new ArgumentError("digital pins are not available");
			if (_config.digitalPins[pinNum] == null) throw new ArgumentError("digital pin is not available at " + pinNum);
			return _ioPorts[_config.digitalPins[pinNum]];
		}

		/**
		 * @return ポート数
		 *
		 */
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

		/**
		 * @private
		 *
		 */
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