package funnel
{
	
	import funnel.ioport.Port;
	
	public class Configuration
	{
		public static const GAINER_MODE1:Array = [
		    Port.AIN,  Port.AIN,  Port.AIN,  Port.AIN,
		    Port.DIN,  Port.DIN,  Port.DIN,  Port.DIN,
		    Port.AOUT, Port.AOUT, Port.AOUT, Port.AOUT,
		    Port.DOUT, Port.DOUT, Port.DOUT, Port.DOUT,
		    Port.DOUT,  Port.DIN ];
	
		public static const GAINER_MODE2:Array = [
		    Port.AIN,  Port.AIN,  Port.AIN,  Port.AIN,
		    Port.AIN,  Port.AIN,  Port.AIN,  Port.AIN,
		    Port.AOUT, Port.AOUT, Port.AOUT, Port.AOUT,
		    Port.DOUT, Port.DOUT, Port.DOUT, Port.DOUT,
		    Port.DOUT,  Port.DIN ];
		    
		public static const GAINER_MODE3:Array = [
		    Port.AIN,  Port.AIN,  Port.AIN,  Port.AIN,
		    Port.DIN,  Port.DIN,  Port.DIN,  Port.DIN,
		    Port.AOUT, Port.AOUT, Port.AOUT, Port.AOUT,
		    Port.AOUT, Port.AOUT, Port.AOUT, Port.AOUT,
		    Port.DOUT,  Port.DIN ];
		    
		public static const GAINER_MODE4:Array = [
		    Port.AIN,  Port.AIN,  Port.AIN,  Port.AIN,
		    Port.AIN,  Port.AIN,  Port.AIN,  Port.AIN,
		    Port.AOUT, Port.AOUT, Port.AOUT, Port.AOUT,
		    Port.AOUT, Port.AOUT, Port.AOUT, Port.AOUT,
		    Port.DOUT,  Port.DIN ];
		    
		public static const GAINER_MODE5:Array = [
		    Port.DIN,  Port.DIN,  Port.DIN,  Port.DIN,
		    Port.DIN,  Port.DIN,  Port.DIN,  Port.DIN,
		    Port.DIN,  Port.DIN,  Port.DIN,  Port.DIN,
		    Port.DIN,  Port.DIN,  Port.DIN,  Port.DIN];
		    
		public static const GAINER_MODE6:Array = [
		    Port.DOUT, Port.DOUT, Port.DOUT, Port.DOUT,
		    Port.DOUT, Port.DOUT, Port.DOUT, Port.DOUT,
		    Port.DOUT, Port.DOUT, Port.DOUT, Port.DOUT,
		    Port.DOUT, Port.DOUT, Port.DOUT, Port.DOUT];
		    
		public static const GAINER_MODE7:Array = [
		    Port.AOUT, Port.AOUT, Port.AOUT, Port.AOUT, Port.AOUT, Port.AOUT, Port.AOUT, Port.AOUT,
		    Port.AOUT, Port.AOUT, Port.AOUT, Port.AOUT, Port.AOUT, Port.AOUT, Port.AOUT, Port.AOUT,
		    Port.AOUT, Port.AOUT, Port.AOUT, Port.AOUT, Port.AOUT, Port.AOUT, Port.AOUT, Port.AOUT,
		    Port.AOUT, Port.AOUT, Port.AOUT, Port.AOUT, Port.AOUT, Port.AOUT, Port.AOUT, Port.AOUT,
		    Port.AOUT, Port.AOUT, Port.AOUT, Port.AOUT, Port.AOUT, Port.AOUT, Port.AOUT, Port.AOUT,
		    Port.AOUT, Port.AOUT, Port.AOUT, Port.AOUT, Port.AOUT, Port.AOUT, Port.AOUT, Port.AOUT,
		    Port.AOUT, Port.AOUT, Port.AOUT, Port.AOUT, Port.AOUT, Port.AOUT, Port.AOUT, Port.AOUT,
		    Port.AOUT, Port.AOUT, Port.AOUT, Port.AOUT, Port.AOUT, Port.AOUT, Port.AOUT, Port.AOUT];
	
		public static const GAINER_MODE8:Array = [
		    Port.DIN,  Port.DIN,  Port.DIN,  Port.DIN,
		    Port.DIN,  Port.DIN,  Port.DIN,  Port.DIN,
		    Port.DOUT, Port.DOUT, Port.DOUT, Port.DOUT,
		    Port.DOUT, Port.DOUT, Port.DOUT, Port.DOUT];
	}
}