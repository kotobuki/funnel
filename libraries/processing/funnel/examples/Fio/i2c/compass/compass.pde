import processing.funnel.*;
import processing.funnel.i2c.*;

Fio fio;
HMC6352 compass;
float heading;

void setup()
{
  size(200, 200);
    
  int[] moduleIDs = {1};

  fio = new Fio(this,moduleIDs,Fio.FIRMATA);
  compass = new HMC6352(fio.iomodule(1));

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

  
  //
  stroke(230,30,40);
  line(0,0,80*cos(radians(0)),80*sin(radians(0)));

  stroke(30,204,10);
  line(0,0,80*cos(radians(compass.heading)),80*sin(radians(compass.heading)));

  popMatrix();
}


void keyPressed()
{
  if(key=='c'){
    compass.enterCalibrationMode();
   
    float start = millis();
    
    float t=0;
    int i=0;
    while(t < 20000){
    
      delay(1000);
      println(i++);
      t = millis() - start;
    } 
    compass.exitCalibrationMode();
    println("finish");
  
  }
}

void mousePressed()
{
  compass.endUpdate();
}

void mouseReleased()
{
  compass.beginUpdate();
}

