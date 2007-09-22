/*
    The model for asynchronous computation used in this class is heavily inspired 
    by Mochikit(http://mochikit.com/) and Twisted(http://twistedmatrix.com/trac/).
*/

package funnel.async
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class Deferred
	{
		private var _chain:Array;
    	private var _results:Array;
	    private var _paused:Boolean;
	    private var _fired:Number;
	    private var _canceller:Function;
	    private var _silentlyCancelled:Boolean;
	    private var _chained:Boolean;
	
	    public function Deferred(canceller:Function = null)
	    {
	        _chain = [];
			_fired = -1;
	      	_paused = false;
	        _results = [null, null];
	        _canceller = canceller;
	        _silentlyCancelled = false;
	        _chained = false;
	    }
	    
	    public function set onResult(f:Function):void {
	    	addCallback(null, f);
	    }
	    
	    public function set onFault(f:Function):void {
	    	addErrback(null, f);
	    }
	    
	    public static function createDeferredFunctionWithEvent(o:EventDispatcher, f:Function, callbackEvents:Array, errbackEvents:Array = null, canceller:Function = null):Function {
	    	return function(...arguments):Deferred {
	    		var d:Deferred = new Deferred(function():void {
	    			removeAllListeners();
	    			canceller.apply(o);
	    		});
	    		var events:Array = callbackEvents;
	    		if(errbackEvents) events = callbackEvents.concat(errbackEvents);
	    		
	    		var removeAllListeners:Function = function():void {
	    			for each (var event:String in events) 
	    				o.removeEventListener(event, onReply);
	    		}
	    		
	    		var onReply:Function = function(event:Event):void {
	    			removeAllListeners();
	    			if (callbackEvents.indexOf(event.type) != -1)
	    			    d.callback();
	    			else if (errbackEvents.indexOf(event.type) != -1)
	    			    d.errback(new Error(event.type));
	    		}
	    		
	    		for each (var event:String in events)
	    			o.addEventListener(event, onReply);
	    		
	    		try {
	    			f.apply(o, arguments);
	    		} catch (e:Error) {
	    			removeAllListeners();
	    			d.errback(e);
	    		}
	    		return d;
	    	}
	    }
	
		public function cancel():void {
			if (_fired == -1) {
				if (_canceller != null)
				    _canceller();
				else
				    _silentlyCancelled = true;
				    
				if (_fired == -1)
				    errback(new Error("CancelledError"));
				    
			} else if (_fired === 0 && _results[0] is Deferred) {
				_results[0].cancel();
			}
		}
		
		private function _pause():void {
			_paused = true;
		}
		
		private function _unpause():void {
			_paused = false;
			if (!_paused && _fired >= 0)
			    _fire();
		}
	
	    private function _continue(res:* = null):void
	    {
	        _resback(res);
	        _unpause();
	    }
	
	    private function _resback(res:*):void
	    {
	        _fired = ((res is Error) ? 1 : 0);
	        _results[_fired] = res;
	        _fire();
	    }
	    
	    private function _check():void {
	    	if (_fired != -1) {
	    		if (!_silentlyCancelled) 
	    			throw new Error("AlreadyCalledError");
	    		
	    		_silentlyCancelled = false;
	    	}
	    }
	
	    public function callback(res:* = null):void
	    {

	    	_check();
	    	if (res is Deferred)
	    	    throw new Error("Deferred instances can only be chained if they are the result of a callback");
	        _resback(res);
	    }
	    
	    public function errback(res:Error):void
	    {
	    	_check();
	        _resback(res);
	    }

	    public function addBoth(obj:Object, func:Function, ...args):Deferred
	    {
	    	var fn:Function = _bind(obj, func, args);
	        return addCallbacks(fn, fn);
	    }

	    public function addCallback(obj:Object, func:Function, ...args):Deferred
	    {
			var fn:Function = _bind(obj, func, args);
	        return addCallbacks(fn, null);
	    }
	
	    public function addErrback(obj:Object, func:Function, ...args):Deferred
	    {
	    	var fn:Function = _bind(obj, func, args);
	        return addCallbacks(null, fn);
	    }
	
	    public function addCallbacks(cb:Function, eb:Function):Deferred
	    {
	    	if (_chained)
	    	    throw new Error("Chained deferreds can not be re-used");
	    	    
	        _chain.push([cb, eb]);
	        
	        if (_fired >= 0)
	            _fire();
	            
	        return this;
	    }
	
	    private function _fire():void
	    {
			var res:* = _results[_fired];
			var self:Deferred = this;
			var cb:Function = null;
			while (_chain.length > 0 && _paused == 0) {
				var pair:Array = _chain.shift();		
				var f:Function = pair[_fired];
				
				if (f == null) 
					continue;
				
				try {
					if (res) 
					    res = f(res);
					else
					    res = f();
					
					_fired = ((res is Error) ? 1 : 0);

					if (res is Deferred) {
						cb = _continue;
						_pause();
					}
					
				} catch (err:Error) {
					_fired = 1;
					if (!(err is Error))
					    err = new Error("GenericError");
					res = err;
				}
			}
			_results[_fired] = res;
			if (cb != null && _paused) {
				res.addBoth(null, cb);
				res._chained = true;
			}
	    }
	    
	    private static function _bind(o:Object, f:Function, args:Array):Function {
			return function():* {
				if (args.length > 0)
				    return f.apply(o, args);
				else
				    return f.apply(o, arguments);
			}
		}
	}
}