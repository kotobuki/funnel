/*
Gainer
 filter test (SetPoint) 2point
 */
import processing.funnel.*;

Gainer gainer;

PFont myFont;

void setup()
{ 
  size(200,200);
  smooth();

  myFont = loadFont("CourierNewPSMT-24.vlw");
  textFont(myFont, 24);

  SetPoint separator = new SetPoint(0.5,0.01);
  separator.addPoint(0.8,0.01);

  gainer = new Gainer(this,Gainer.MODE1);
  gainer.analogInput(0).addFilter(separator);
}

void draw()
{
  background(0);

  ellipse(width/2,height/2,40,40);
  text("value:"+gainer.analogInput(0).value,30,70);
}

void change(PinEvent e)
{
  if(e.target == gainer.analogInput(0)){
    switch(int(e.target.value)){
    case 0:
      fill(203,100,0);
      break;
    case 1:
      fill(203,0,100);
      break;
    case 2:
      fill(103,203,0);
      break;
    }    
    //println("change  " + e.target.number + " " + e.target.value);
  }
}



