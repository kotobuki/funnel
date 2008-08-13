/*
Fio
analog out 
*/

import processing.funnel.*;

Fio fio;

void setup()
{
  size(200,200);
  frameRate(25);
  
  Configuration config = Fio.FIRMATA;
  config.setDigitalPinMode(10,Fio.PWM);
  
  int[] nodeIDs = {1};
  fio = new Fio(this,nodeIDs,config);
  fio.autoUpdate = true;

}

void draw()
{
  background(170);
  
  float val = float(mouseX)/width;
  fio.iomodule(1).port(10).value = val;
}
  



