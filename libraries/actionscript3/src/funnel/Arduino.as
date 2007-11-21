package funnel
{
	public class Arduino extends IOSystem
	{
		private var _port:Function;
		private var _analogPins:Array;
		private var _digitalPins:Array;
		
		public function Arduino(config:Configuration = null, host:String = "localhost", portNum:Number = 9000, samplingInterval:int = 33) {
			if (config == null) config = Configuration.ARDUINO;
			super([config], host, portNum, samplingInterval);
			
			_port = module(0).port;
			_analogPins = config.analogPins;
			_digitalPins = config.digitalPins;
		}
		
		public function analogPin(pinNum:uint):Port {
			return _port(_analogPins[pinNum]);
		}
		
		public function digitalPin(pinNum:uint):Port {
			return _port(_digitalPins[pinNum]);
		}
		
	}
}