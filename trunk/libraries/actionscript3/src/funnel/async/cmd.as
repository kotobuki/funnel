package funnel.async
{
	public function cmd(f:Function, ...args):Function {
		return function():* {
			return f.apply(null, args);
		}
	}
}
