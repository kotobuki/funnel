package funnel.filter
{
	import flash.utils.*;
	import flash.events.TimerEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import funnel.filter.IFilter;
	
	public class Osc extends EventDispatcher implements IGenerator
	{	
		private var _wave:Function;
		private var _freq:Number;
		private var _amplitude:Number;
		private var _offset:Number;
		private var _phase:Number;
		private var _repeatCount:Number;
		private var _time:uint;
		private var _oldTime:int;
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
			repeatCount:Number = 0
		) {
			if (freq == 0) throw new Error("Frequency should be larger than 0...");
			
			if (wave == null) _wave = SIN;
			else _wave = wave;
			_freq = freq;
			_amplitude = amplitude;
			_offset = offset;
			_phase = phase;
			_repeatCount = repeatCount;
		}
		
		public function get value():Number {
			return _value;
		}
		
		public function start():void {
			stop();
			_timer.addEventListener(TimerEvent.TIMER, update);
		}
		
		private function stop():void {
			_time = 0;
			_oldTime = getTimer();
			_timer.removeEventListener(TimerEvent.TIMER, update);
		}
		
		public function update(event:Event = null):void {
			_time += getTimer() - _oldTime;
			_oldTime = getTimer();
			var sec:Number = _time / 1000;
			
			if (_repeatCount != 0 && _freq * sec >= _repeatCount) {
				_timer.removeEventListener(TimerEvent.TIMER, update);
				return;
			}
			
			_value = _amplitude * _wave(_freq * (sec + _phase)) + _offset;
			dispatchEvent(new Event(Event.CHANGE));
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