import processing.funnel.*;
import processing.funnel.i2c.*;


Fio fio;
LSM303DLH compass;
float heading;

void setup()
{
  size(400, 200);
    
  int[] moduleIDs = {1};
  Fio.withoutServer = true;

  Configuration config = Fio.FIRMATA;
                                     
  fio = new Fio(this,moduleIDs,config);
  compass = new LSM303DLH(fio.iomodule(1));
  double[][] dtrans = {{0.871045, 0.0341145, -0.00556378}, {0.0341145, 0.912459, -0.0491539}, {-0.00556378, -0.0491539, 0.967118}};
  compass.m.setEllipsoidTransformMatrix(dtrans);
  double[] dcent = {-69.1986, 97.7790, 130.019};
  compass.m.setEllipsoidCenter(dcent);	
  
  smooth();
  strokeWeight(2.0f);

  ellipseMode(RADIUS);
  fill(230,230,230);

}

void draw()
{
  pushMatrix();
  background(200,200,200);
  translate(width/2,height/2);
  
  stroke(10,10,40);
  ellipse(0,0,85,85);

  //println(compass.m.getRawData());
  stroke(230,30,40);
  line(0,0,80*cos(radians(0)),80*sin(radians(0)));

  stroke(30,204,10);
  line(0,0,80*cos(compass.heading),80*sin(compass.heading));

  popMatrix();

}

