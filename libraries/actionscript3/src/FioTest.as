package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import funnel.*;
	
	public class FioTest extends Sprite
	{
		public function FioTest() {
			var fio:Fio = new Fio([4, 5]);
			var osc:Osc = new Osc();
			osc.start();
			fio.module(ALL).port(10).filters = [osc];
		}
	}
}