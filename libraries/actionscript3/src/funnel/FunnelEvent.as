package funnel {

	import flash.events.Event;

	/**
	 * This is the class to express IOSystem's non-error events
	 */
	public class FunnelEvent extends Event {
		/**
		 * This event will be sent when a Firmata String is received from an I/O module
		 */
		public static const FIRMATA_STRING:String = "firmataString";

		/**
		 * This event will be sent when I2C power pins of an I/O module is ready
		 */
		public static const I2C_POWER_PINS_READY:String = "i2cPowerPinsReady";

		/**
		 * This event will be sent when an I/O module is ready
		 */
		public static const READY:String = "ready";

		private var _message:String;
		private var _moduleId:int;

		public function FunnelEvent(type:String, moduleId:int = 0, message:String = null, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			this._moduleId = moduleId;
			this._message = message;
		}

		public override function clone():Event {
			return new FunnelEvent(this.type, this._moduleId, this._message, this.bubbles, this.cancelable);
		}

		public function get message():String {
			return this._message;
		}

		public function get moduleId():int {
			return this._moduleId;
		}
	}
}