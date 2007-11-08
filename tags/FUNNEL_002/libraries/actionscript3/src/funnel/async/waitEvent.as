package funnel.async
{
	import funnel.async.Task;
	import flash.events.Event;
	import flash.events.EventDispatcher;

	public function waitEvent(o:EventDispatcher, type:String, ...errorTypes):Task {
		
		var task:Task = new Task();

		task.anyway = function(res:*):* {
			o.removeEventListener(type, task.complete);
			for each (var errorType:String in errorTypes) {
				o.removeEventListener(errorType, task.fail);
			}
			return res;
		}
		
		o.addEventListener(type, task.complete);
		for each (var errorType:String in errorTypes) {
			o.addEventListener(errorType, task.fail);
		}
			
		return task;
	}
}
