package funnel.filter
{
	import flash.utils.*;
	import flash.events.TimerEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import funnel.filter.IFilter;
	import funnel.event.GeneratorEvent;
	
	public class Osc extends EventDispatcher implements IGenerator
	{	
		public var wave:Function;
		public var freq:Number;
		public var amplitude:Number;
		public var offset:Number;
		public var phase:Number;
		public var times:Number;
		
		private var _time:uint;
		private var _startTime:int;
		private var _value:Number;
	
		private static var _timer:Timer = function():Timer {
			var timer:Timer = new Timer(33);
			timer.start();
			return timer;
		}();
		
		public static function set serviceInterval(interval:uint):void {
			_timer.delay = interval;
		}
		
		public static function get serviceInterval():uint {
			return _timer.delay;
		}
		
		public function Osc(
			wave:Function = null,
			freq:Number = 1,
			amplitude:Number = 1,
			offset:Number = 0,
			phase:Number = 0,
			times:Number = 0
		) {
			if (freq == 0) throw new Error("Frequency should be larger than 0...");
			
			if (wave == null) this.wave = SIN;
			else this.wave = wave;
			
			this.freq = freq;
			this.amplitude = amplitude;
			this.offset = offset;
			this.phase = phase;
			this.times = times;
			
			reset();
		}
		
		public function get value():Number {
			return _value;
		}
		
		public function start():void {
			stop();
			_timer.addEventListener(TimerEvent.TIMER, autoUpdate);
			_startTime = getTimer();
			autoUpdate(null);
		}
		
		public function stop():void {
			_timer.removeEventListener(TimerEvent.TIMER, autoUpdate);
		}
		
		public function reset():void {
			_time = 0;
		}
		
		public function update(interval:int = -1):void {
			if (interval < 0) _time += _timer.delay;
			else _time += interval;
			
			computeValue();
		}
		
		private function autoUpdate(event:Event):void {
			_time = getTimer() - _startTime;
			computeValue();
		}
		
		private function computeValue():void {
			var sec:Number = _time / 1000;
			
			if (times != 0 && freq * sec >= times) {
				stop();
				sec = times / freq;
			}
			
			_value = amplitude * wave(freq * (sec + phase)) + offset;
			dispatchEvent(new GeneratorEvent(GeneratorEvent.UPDATE));
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
		
		public static function IMPULSE(val:Number):Number {
			if (val <= 1) return 1;
			else return 0;
		}
	}
}