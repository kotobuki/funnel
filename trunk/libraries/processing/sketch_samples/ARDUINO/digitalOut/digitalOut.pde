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
  
  Configuration config = ARDUINO.USER;
  config.setDigitalPinMode(ledPin,ARDUINO.OUT);
  arduino = new Funnel(this,config);
  arduino.autoUpdate = true;

}

void draw()
{
  background(170);
  
  if(mousePressed){
    arduino.port(ARDUINO.digitalOutput[ledPin]).value = 1.0;
  }else{
    arduino.port(ARDUINO.digitalOutput[ledPin]).value = 0.0;
  }

}


