package processing.funnel;

import java.io.*;

public class LibUtil {

	  static public File getContentFile(String name) {
		    String path = System.getProperty("user.dir");

		    String osname = System.getProperty("os.name");
		    if (osname.indexOf("Mac") != -1) {
//		      <key>javaroot</key>
//		      <string>$JAVAROOT</string>
		      String javaroot = System.getProperty("javaroot");
		      if (javaroot != null) {
		        path = javaroot;
		      }
		    }
		    File working = new File(path);
		    return new File(working, name);
	  }	
	  
	  static public InputStream getLibStream(String filename) throws IOException {
		    return new FileInputStream(new File(getContentFile("lib"), filename));
	  }
	  
	  /**
	   * returns true if Processing is running on a Mac OS X machine.
	   */
	  static public boolean isMacOS() {
	    //return PApplet.platform == PConstants.MACOSX;
	    return System.getProperty("os.name").indexOf("Mac") != -1;
	  }


	  /**
	   * returns true if running on windows.
	   */
	  static public boolean isWindows() {
	    //return PApplet.platform == PConstants.WINDOWS;
	    return System.getProperty("os.name").indexOf("Windows") != -1;
	  }


	  /**
	   * true if running on linux.
	   */
	  static public boolean isLinux() {
	    //return PApplet.platform == PConstants.LINUX;
	    return System.getProperty("os.name").indexOf("Linux") != -1;
	  }

}
