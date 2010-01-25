/*
Fio
digital out (d13)
*/
import processing.funnel.*;

Fio fio;
int ledPinNumber = 13;
Pin ledPin;

void setup()
{
  size(200,200);
  
  int[] fioIDs = {1};
  Configuration config = Fio.FIRMATA;
  config.setDigitalPinMode(ledPinNumber,Fio.OUT);
  
  fio = new Fio(this,fioIDs,config);
  ledPin = fio.iomodule(1).digitalPin(ledPinNumber);
}

void draw()
{
  background(170);

}

void mousePressed()
{
  ledPin.value = 1.0;
}

void mouseReleased()
{
  ledPin.value = 0.0;
}
