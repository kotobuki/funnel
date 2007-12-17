/*
Gainer
filter test (SetPoint) 1point
*/
import processing.funnel.*;

Gainer gainer;
SetPoint border;

int backgroundcolor = 100;
PFont myFont;

void setup()
{ 
  size(200,200);
  background(0);
  myFont = loadFont("CourierNewPSMT-24.vlw");
  textFont(myFont, 24);
  
  frameRate(25);
 
  gainer = new Gainer(this,Gainer.MODE1);
  border = new SetPoint(0.3,0.1);

  Filter filters[] = {border};
  gainer.analogInput(0).filters = filters;
}

void draw()
{
  background(backgroundcolor);
  text("value:"+gainer.analogInput(0).value,30,80);
  
}

void risingEdge(PortEvent e)
{
  backgroundcolor=170;

  println("rising  " + e.target.number + " " + e.target.value);
}

void fallingEdge(PortEvent e)
{
  backgroundcolor=100;

  println("falling  " + e.target.number + " " + e.target.value);;  
}

