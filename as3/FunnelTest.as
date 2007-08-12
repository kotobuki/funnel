package {
	import flash.display.*;
	import funnel.*;
	import flash.events.Event;

	public class FunnelTest extends Sprite
	{
		include "shortcut.as"
		private var f:Funnel;
		private var frameCount:uint;
		
		public function FunnelTest()
		{
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			f = new Funnel(GAINER_MODE1);
			f.autoUpadate = false;
			
			frameCount = 0;
		}
		
		private function onEnterFrame(event:Event):void {
			f.port[13].value = (frameCount % 2 == 0)?1:0;
			f.port[13].update();
			frameCount++;
		}
	}
}
