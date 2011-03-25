package funnel.i2c {
	import flash.events.Event;
	
	public class GyroEvent extends Event {
		public static const GYRO_READY:String = "gyroReady";
		public static const CALIBRATION_PROGRESS:String = "calibrationProgress";
		public static const CALIBRATION_COMPLETE:String = "calibrationComplete";
		
		private var _progress:uint;
		
		public function GyroEvent(type:String, prog:uint = 0) {
			super(type);
			
			_progress = prog;
		}
		
		override public function clone():Event {
			return new GyroEvent(type);
		}
		
		/**
		 * get the current progress of the calibration routine
		 */
		public function get progress():uint {
			return _progress;
		}
		
		public function set progress(value:uint):void {
			_progress = value;
		}
	}
	
}