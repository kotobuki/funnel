/*
Gainer
digital in
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
  text("digitalInput[0]: " + gainer.port(GAINER.digitalInput[0]).value,10,80); 
  text("digitalInput[1]: " + gainer.port(GAINER.digitalInput[1]).value,10,110);
  text("digitalInput[2]: " + gainer.port(GAINER.digitalInput[2]).value,10,140);
  text("digitalInput[3]: " + gainer.port(GAINER.digitalInput[3]).value,10,170);
}
  



