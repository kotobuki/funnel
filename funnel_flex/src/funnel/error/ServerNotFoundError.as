package funnel.error
{
	public class ServerNotFoundError extends Error {
		public function ServerNotFoundError() {
			super("Funnel server was not found...");
		}
	}
}