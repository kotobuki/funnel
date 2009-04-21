package processing.funnel;

import java.util.Collections;
import java.util.Comparator;
import java.util.ListIterator;
import java.util.Vector;

/**
 * @author endo
 * @version 1.0
 * 
 */
public class SetPoint implements Filter{

	public Vector<Point> point = new Vector<Point>();
	
	private float lastStatus = 0;
	
	
	public SetPoint(float threshold, float hysteresis){
		
		addPoint(threshold,hysteresis);
	}
	/**
	 *  return "SetPoint"
	 */
	public String getName(){
		return "SetPoint";
	}
	
	public float processSample(float in, float[] buffer){
		
		float status = 0;
		
		int index = 0;
		ListIterator<Point> it = point.listIterator();
		for(ListIterator<Point> i = it;it.hasNext();){
			index = i.nextIndex();
			Point p = i.next();
			if(in > p.threshold + p.hysteresis){
				status = index+1;
				continue;
			}else if(in < p.threshold - p.hysteresis){
				status = index;
			}else{
				status = lastStatus;
			}	
			break;

		}
		lastStatus = status;
		
//		System.out.print("processSample " + in + " ");
//		System.out.println(lastStatus);
		return lastStatus;
	
	}
	
	public void addPoint(float threshold,float hysteresis){
		
		point.add(new Point(threshold,hysteresis));
		
		Collections.sort(point, new ThresholdComparatorUpper());

//		ListIterator it = point.listIterator();
//		System.out.println("addPoint");
//		for(ListIterator i = it;it.hasNext();){
//			int index = i.nextIndex();
//			Point p = (Point)i.next();
//			
//			System.out.println(index + "  " + p.threshold);
//
//
//		}
	}
	
	public void removePoint(float threshold){
		ListIterator<Point> it = point.listIterator();
		for(ListIterator<Point> i = it;it.hasNext();){
			Point p = i.next();
			if(p.threshold == threshold){
				point.remove(p);
				break;
			}
		}	
	}
	
	
	class Point{
		public float threshold;
		public float hysteresis;
		
		public Point(float t,float h){
			threshold = t;
			hysteresis = h;
		}
	}
	
	//è∏èáÇ…ï‘Ç∑
	private static class ThresholdComparatorUpper implements Comparator<Point> {
	    public int compare(Point p1, Point p2) {
	      
	      Float f1 = new Float(p1.threshold);
	      Float f2 = new Float(p2.threshold);
	      
	      return f1.compareTo(f2);
	    }
	}
}

