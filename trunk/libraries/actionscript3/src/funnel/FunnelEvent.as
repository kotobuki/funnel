package funnel {

	import flash.events.Event;

	/**
	 * This is the class to express IOSystem's non-error events
	 */
	public class FunnelEvent extends Event {
		/**
		 * This event will be sent when I2C power pins of an I/O module is ready
		 */
		public static const I2C_POWER_PINS_READY:String = "i2cPowerPinsReady";

		/**
		 * This event will be sent when an I/O module is ready
		 */
		public static const READY:String = "ready";

		public function FunnelEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
		}

	}
}