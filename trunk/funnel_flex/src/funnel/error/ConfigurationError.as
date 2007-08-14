package funnel.error
{
	public class ConfigurationError extends Error {
		public function ConfigurationError() {
			super("Specified configuration is invalid...");
		}
	}
}