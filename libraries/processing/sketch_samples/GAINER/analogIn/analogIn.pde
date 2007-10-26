/*
Gainer
analog in
*/

import processing.funnel.*;

Funnel gainer;
PFont myFont;

void setup()
{
  size(400,250);
  frameRate(25);
  
  myFont = loadFont("CourierNewPSMT-24.vlw");
  textFont(myFont, 24);
  
  gainer = new Funnel(this,GAINER.CONFIGURATION_1);
 
}

void draw()
{
  background(0);
  text("analogInput[0]: " + gainer.port(GAINER.analogInput[0]).value,10,80); 
  text("analogInput[1]: " + gainer.port(GAINER.analogInput[1]).value,10,110);
  text("analogInput[2]: " + gainer.port(GAINER.analogInput[2]).value,10,140);
  text("analogInput[3]: " + gainer.port(GAINER.analogInput[3]).value,10,170);
}
  



