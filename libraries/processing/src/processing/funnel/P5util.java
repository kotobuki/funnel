package processing.funnel;

public class P5util {

	static String getFunnelLibraryPath(){

		String classPath = System.getProperty("java.class.path");
		String seperator=";";
		if(isMac()){
			seperator = ":";
		}
		String[] libraries = classPath.split(seperator);
		String myLibraryPath="";

		for(int i=0;i<libraries.length;i++){
			
			int index = libraries[i].lastIndexOf("funnel.jar");
			if(index != -1){
				myLibraryPath = libraries[i].substring(0,index);
				break;
			}
		}
		return myLibraryPath;
	}
	
	static boolean isPDE(){
		String classPath = System.getProperty("java.class.path");
		String[] libraries = classPath.split(";");

		for(int i=0;i<libraries.length;i++){
			if(libraries[i].lastIndexOf("pde.jar") != -1){
				return true;
			}
		}	
		
		return false;
	}
	
	static boolean isMac()	{
		String osname = System.getProperty("os.name");
		if (osname.indexOf("Mac") != -1) {
			return true;
		}
		return false;
	}
}
