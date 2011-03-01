/*
Gainer
analog in
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
  text("analogInput[0]: " + gainer.analogInput(0).value,10,80);
  text("analogInput[1]: " + gainer.analogInput(1).value,10,110);
  text("analogInput[2]: " + gainer.analogInput(2).value,10,140);
  text("analogInput[3]: " + gainer.analogInput(3).value,10,170);
}

