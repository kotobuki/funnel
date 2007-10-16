package funnel.async
{
	import funnel.async.Task;
	
	public function turn(...funcs):Function {
		var task:Task = new Task(funcs);
		return task.complete;
	}
}
