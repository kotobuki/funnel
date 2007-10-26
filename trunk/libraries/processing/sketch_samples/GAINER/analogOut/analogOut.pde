/*
Gainer
analog out (aout0)
*/

import processing.funnel.*;

Funnel gainer;

void setup()
{
  size(200,200);
  frameRate(25);
  
  gainer = new Funnel(this,GAINER.CONFIGURATION_1);
  gainer.autoUpdate = true;
}

void draw()
{
  background(170);
  
  float val = float(mouseX)/width;
  gainer.port(GAINER.analogOutput[0]).value = val;
}
  



