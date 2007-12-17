/*
Fio
analog out (aout0)
*/

import processing.funnel.*;

Fio fio;

void setup()
{
  size(200,200);
  frameRate(25);
  
  int[] moduleIDs = {2};
  fio = new Gainer(this,moduleIDs);
  gainer.autoUpdate = true;
}

void draw()
{
  background(170);
  
  float val = float(mouseX)/width;
  fio.iomodule(0xFFFF).port(10).value = val;
}
  



