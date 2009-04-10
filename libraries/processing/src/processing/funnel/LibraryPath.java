package processing.funnel;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;

import processing.app.Base;
import processing.app.Platform;
import processing.core.PApplet;

public class LibraryPath {

	static String getFunnelLibraryPath(){

		String libraryPath = "";
		
		try{
			
			Platform platform;
			Class platformClass = Class.forName("processing.app.Platform");
			if (Base.isMacOS()) {
				platformClass = Class.forName("processing.app.macosx.Platform");
			} else if (Base.isWindows()) {
				platformClass = Class.forName("processing.app.windows.Platform");
			} else if (Base.isLinux()) {
				platformClass = Class.forName("processing.app.linux.Platform");
			}
			platform = (Platform) platformClass.newInstance();
			platform.init(null);
	      
		    File settingPath = new File(platform.getSettingsFolder(),"preferences.txt");
		    System.out.println(settingPath.toString());

			InputStream input = new FileInputStream(settingPath);
			String[] lines = PApplet.loadStrings(input);  // Reads as UTF-8
			for(int i=0;i<lines.length;i++){
				String line = lines[i];
				if(line.length()==0 || line.charAt(0)=='#') continue;
			      int equals = line.indexOf('=');
			      if (equals != -1) {
			        String key = line.substring(0, equals).trim();
			        String value = line.substring(equals + 1).trim();
			        if(key.equals("sketchbook.path")){
			        	System.out.println("  " + key + "  "+ value);
			        	libraryPath = value + File.separator + "libraries" + File.separator + 
			        	"funnel" + File.separator + "library" + File.separator;
			        }
			      }
			}
		} catch (IOException e1) {
			e1.printStackTrace();
	    } catch (Exception e) {
	      Base.showError("Problem Setting the Platform",
	                     "An unknown error occurred while trying to load\n" +
	                     "platform-specific code for your machine.", e);
	    }
	    
		return libraryPath;
	}
}
