/*
	The model for asynchronous computation used in this class is heavily inspired 
	by Mochikit(http://mochikit.com/) and Twisted(http://twistedmatrix.com/trac/).
*/

package funnel
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	/**
	 * 非同期処理を同期化するためのクラスです。
	 * @private
	 * 
	 */ 
	public class Task {
		
		private var chain:Array;
		private var finished:Boolean;
		private var res:*;
		private var onFired:Function;
		protected var status:int;
		
		public function Task(funcs:Array = null) {
			chain = [];
			finished = false;
			status = -1;
			
			if (funcs != null) {
				for each (var f:Function in funcs) {
					chain.push([f, null]);
				}
			}
		}
		
		static public function bindArgs(f:Function, args:Array):Function {
			return function():* {
				return f.apply(null, args);
			}
		}
		
		static public function waitEvent(o:EventDispatcher, type:String, ...errorTypes):Task {
			var task:Task = new Task();
	
			task.addBoth(function(res:*):* {
				o.removeEventListener(type, task.complete);
				for each (var errorType:String in errorTypes) {
					o.removeEventListener(errorType, task.fail);
				}
				return res;
			});
			
			o.addEventListener(type, task.complete);
			for each (var errorType:String in errorTypes) {
				o.addEventListener(errorType, task.fail);
			}
				
			return task;
		}
		
		public function addCallback(f:Function, ...args):Task {
			if (args.length > 0) {
				f = bindArgs(f, args);
			}
			chain.push([f, null]);
			notify();
			return this;
		}
		
		public function addErrback(f:Function, ...args):Task {
			if (args.length > 0) {
				f = bindArgs(f, args);
			}
			chain.push([null, f]);
			notify();
			return this;
		}
		
		public function addBoth(f:Function, ...args):Task {
			if (args.length > 0) {
				f = bindArgs(f, args);
			}
			chain.push([f, f]);
			notify();
			return this;
		}
		
		private function notify():void {
			if (finished) {
				finished = false;
				fire();
			}
		}
		
		public function complete(res:* = null):Task {
			if (status != -1) throw Error('complete() can be called only once');
			status = 0;
			this.res = res;
			fire();
			return this;
		}
		
		public function fail(res:* = null):Task {
			if (status != -1) throw Error('fail() can be called only once');
			status = 1;
			this.res = res;
			fire();
			return this;
		}
		
		public function cancel():void {
			if (status == -1) {
				onCanceled();
				if (status == -1) fail(new Error('task was canceled'));
			} else if (res is Task) {
				res.cancel();
			}
		}
		
		protected function onCanceled():void {}
		
		private function fire():void {
			if (chain.length > 0) {
				var callback:Array = chain.shift();
				var f:Function = callback[status];
				if (f == null) {
					fire();
					return;
				}
				
				if (res) {
					try {res = f(res);}
					catch (argerr:ArgumentError) {res = f();}
				} else {
					res = f();
				}
				
				if (res is Task) {
					res.onFired = resume;
					res.notify();
				} else {
					fire();
				}
			} else {
				finished = true;
				if (onFired != null) onFired();
			}
		}
		
		private function resume():void {
			var task:Task = res as Task;
			task.onFired = null;
			status = task.status;
			res = task.res;
			fire();
		}
	}
}