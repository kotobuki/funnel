/*
ARDUINO 
digital out (13pin)
*/

import processing.funnel.*;

Funnel arduino;

int ledPin = 13;

void setup()
{
  size(200,200);
  frameRate(25);
  
  Configuration config = ARDUINO.FIRMATA;
  config.setDigitalPinMode(ledPin,ARDUINO.OUT);
  arduino = new Funnel(this,config);
  arduino.autoUpdate = true;

}

void draw()
{
  background(170);
  
  if(mousePressed){
    arduino.digitalPin(ledPin).value = 1.0;
  }else{
    arduino.digitalPin(ledPin).value = 0.0;
  }

}


