package funnel.error
{
	public class FunnelError extends Error
	{
		public var eventType:String;
		
		public function FunnelError(message:String = "", eventType:String = "") {
			super(message);
			this.eventType = eventType;
		}
	}
}