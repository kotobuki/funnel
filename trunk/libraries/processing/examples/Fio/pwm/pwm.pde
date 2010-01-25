/*
Fio
pwm (d11)
*/

import processing.funnel.*;

Fio fio;
int ledPin = 11;

void setup()
{
  size(200,200);
  
  Configuration config = Fio.FIRMATA;
  config.setDigitalPinMode(ledPin,Fio.PWM);
  
  int[] nodeIDs = {1};
  fio = new Fio(this,nodeIDs,config);
}

void draw()
{
  background(170);
  
  float val = float(mouseX)/width;
  fio.iomodule(1).digitalPin(ledPin).value = val;
}
  



