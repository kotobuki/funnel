/*
Gainer
analog out (aout0)
*/

import processing.funnel.*;

Gainer gainer;

void setup()
{
  size(200,200);
  
  gainer = new Gainer(this,Gainer.MODE1);
}

void draw()
{
  background(170);
  
  float val = float(mouseX)/width;
  gainer.analogOutput(0).value = val;
}
  



