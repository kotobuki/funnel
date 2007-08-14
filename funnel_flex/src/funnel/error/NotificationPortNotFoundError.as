package funnel.error
{
	public class NotificationPortNotFoundError extends Error
	{
		public function NotificationPortNotFoundError()
		{
			super("Notification port was not found...");
		}
		
	}
}