package funnel
{
	import flash.utils.*;
	import flash.events.TimerEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	/**
	 * @copy GeneratorEvent#UPDATE
	 */
	[Event(name="update",type="GeneratorEvent")]
	
	/**
	 * LEDをふわふわ点滅させたりする時などに使います。回数を1回に設定すると、ワンショットの制御にも使えます。サービス間隔はOsc.serviceIntervalの設定に従います。
	 * 
	 */ 
	public class Osc extends EventDispatcher implements IGenerator
	{	
		/**
		* 波形の関数
		* @default Osc.SIN
		*/		
		public var wave:Function;
		
		/**
		* 周波数
		* @default 1
		*/		
		public var freq:Number;
		
		/**
		* 振幅
		* @default 1
		*/		
		public var amplitude:Number;
		
		/**
		* オフセット
		* @default 0
		*/		
		public var offset:Number;
		
		/**
		* 位相
		* @default 0
		*/		
		public var phase:Number;
		
		/**
		* リピート回数(0で無限回)
		* @default 0
		*/		
		public var times:Number;
		
		private var _time:uint;
		private var _startTime:int;
		private var _value:Number;
	
		private static var _timer:Timer = function():Timer {
			var timer:Timer = new Timer(33);
			timer.start();
			return timer;
		}();
		
		/**
		 * サービス間隔(ms)
		 * 
		 */		
		public static function set serviceInterval(interval:uint):void {
			_timer.delay = interval;
		}
		
		public static function get serviceInterval():uint {
			return _timer.delay;
		}
		
		/**
		 * 
		 * @param wave 波形
		 * @param freq 周波数
		 * @param amplitude 振幅
		 * @param offset オフセット
		 * @param phase 位相
		 * @param times リピート回数
		 * 
		 */		
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
		
		/**
		 * @inheritDoc
		 */		
		public function get value():Number {
			return _value;
		}
		
		/**
		 * Oscの動作を開始します。
		 * 
		 */		
		public function start():void {
			stop();
			_timer.addEventListener(TimerEvent.TIMER, autoUpdate);
			_startTime = getTimer();
			autoUpdate(null);
		}
		
		/**
		 * Oscの動作を停止します。
		 * 
		 */		
		public function stop():void {
			_timer.removeEventListener(TimerEvent.TIMER, autoUpdate);
		}
		
		/**
		 * Oscの状態をリセットします。
		 * 
		 */		
		public function reset():void {
			_time = 0;
		}
		
		/**
		 * 指定したインターバルだけ時間を進めます。引数を省略するとOsc.serviceIntervalだけ時間を進めます。
		 * @param interval 間隔(ms)
		 */		
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
				_value = offset;
      } else {
        _value = amplitude * wave(freq * (sec + phase)) + offset;
      }
			dispatchEvent(new GeneratorEvent(GeneratorEvent.UPDATE));
		}
		
		/**
		 * サイン波
		 */		
		public static function SIN(val:Number):Number {
			return 0.5 * (1 + Math.sin(2 * Math.PI * (val - 0.25)));
		}
		
		/**
		 * 矩形波
		 * 
		 */		
		public static function SQUARE(val:Number):Number {
			return (val%1 <= 0.5) ? 1 : 0;
		}
		
		/**
		 * 三角波
		 * 
		 */ 
		public static function TRIANGLE(val:Number):Number {
      val %= 1;
      return (val <= 0.5) ? (2 * val) : (2 - 2 * val);
		}
		
		/**
		 * ノコギリ波
		 * 
		 */ 
		public static function SAW(val:Number):Number {
			val %= 1;
			if (val <= 0.5) return val + 0.5;
			else return val - 0.5;
		}
		
		/**
		 * インパルス
		 * 
		 */ 
		public static function IMPULSE(val:Number):Number {
			if (val <= 1) return 1;
			else return 0;
		}
	}
}