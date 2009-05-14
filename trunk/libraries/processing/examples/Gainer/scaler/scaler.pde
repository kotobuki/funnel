/*
Gainer
  scaling analog value
*/

import processing.funnel.*;

Gainer gainer;

void setup()
{
  size(400,250);
  
  gainer = new Gainer(this,Gainer.MODE1);
  gainer.analogInput(0).addFilter(new Scaler(0,1,0,255,Scaler.LINEAR,false));
}

void draw()
{
  background(gainer.analogInput(0).value);
}

