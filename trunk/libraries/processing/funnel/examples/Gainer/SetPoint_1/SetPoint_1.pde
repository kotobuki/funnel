/*
Gainer
filter test (SetPoint) 1point
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
  
  gainer = new Gainer(this,Gainer.MODE1);
  gainer.analogInput(0).addFilter(new SetPoint(0.3,0.1));
}

void draw()
{
  background(0);
  
  ellipse(width/2,height/2,40,40);
  text("value:"+gainer.analogInput(0).value,30,70);
}

void risingEdge(PinEvent e)
{
  fill(203,100,0);
  //println("rising  " + e.target.number + " " + e.target.value);
}

void fallingEdge(PinEvent e)
{
  fill(203,200,0);
  //println("falling  " + e.target.number + " " + e.target.value);;  
}

