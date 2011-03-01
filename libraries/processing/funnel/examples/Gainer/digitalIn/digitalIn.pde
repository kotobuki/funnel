/*
Gainer
digital in
*/

import processing.funnel.*;

Gainer gainer;
PFont myFont;

void setup()
{
  size(400,250);
  
  myFont = loadFont("CourierNewPSMT-24.vlw");
  textFont(myFont, 24);
  
  gainer = new Gainer(this,Gainer.MODE1);
 
}

void draw()
{
  background(0);
  text("digitalInput[0]: " + gainer.digitalInput(0).value,10,80); 
  text("digitalInput[1]: " + gainer.digitalInput(1).value,10,110);
  text("digitalInput[2]: " + gainer.digitalInput(2).value,10,140);
  text("digitalInput[3]: " + gainer.digitalInput(3).value,10,170);
}
  



