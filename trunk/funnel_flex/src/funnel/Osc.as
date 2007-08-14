package funnel
{
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.events.Event;
	
	public class Osc
	{
		public var onUpdate:Function;
		
		private var _timer:Timer;
		private var _wave:Function;
		private var _freq:Number;
		private var _amplitude:Number;
		private var _offset:Number;
		private var _phase:Number;
		private var _serviceInterval:uint;
		private var _repeatCount:Number;
		private var _time:uint;
		
		public function Osc(wave:Function = null, freq:Number = 1, amplitude:Number = 1,
							offset:Number = 0, phase:Number = 0, serviceInterval:uint = 33, repeatCount:Number = 0) {
			
			if (freq == 0) throw new Error("Specified frequency is invalid...");
			if (wave == null) _wave = SIN;
			else _wave = wave;
			_freq = freq;
			_amplitude = amplitude;
			_offset = offset;
			_phase = phase;
			_serviceInterval = serviceInterval;
			_repeatCount = repeatCount;
			
			_time = 0;
			_timer = new Timer(serviceInterval);
			_timer.addEventListener(TimerEvent.TIMER, update);
			_timer.start();
		}
		
		private function update(event:Event):void {
			_time += _serviceInterval;
			var sec:Number = _time / 1000;
			var result:Number;
			
			if (_repeatCount != 0 && _freq * sec >= _repeatCount) {
				//sec = _repeatCount / _freq;
				_timer.removeEventListener(TimerEvent.TIMER, update);
				return;
			}
			result = _amplitude * _wave(_freq * (sec + _phase)) + _offset;
			onUpdate(result);
		}
		
		public static function SIN(val:Number):Number {
			return 0.5 * (1 + Math.sin(2 * Math.PI * val));
		}
		
		public static function SQUARE(val:Number):Number {
			return (val%1 <= 0.5) ? 1 : 0;
		}
		
		public static function TRIANGLE(val:Number):Number {
			val %= 1;
			if (val <= 0.25) return 2 * val + 0.5;
			else if (val <= 0.75) return -2 * val + 1.5;
			else return 2 * val - 1.5;
		}
		
		public static function SAW(val:Number):Number {
			val %= 1;
			if (val <= 0.5) return val + 0.5;
			else return val - 0.5;
		}
	}
}