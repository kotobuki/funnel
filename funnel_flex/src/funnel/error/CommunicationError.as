package funnel.error
{
	public class CommunicationError extends Error {
		public function CommunicationError() {
			super("Communication error occurred between funnel server...");
		}
	}
}