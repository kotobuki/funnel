/*
Arduino 
digital out (digital 13pin)
*/

import processing.funnel.*;

Arduino arduino;

int ledPin = 13;

void setup()
{
  size(200,200);

  Configuration config = Arduino.FIRMATA;
  config.setDigitalPinMode(ledPin,Arduino.OUT);

  arduino = new Arduino(this,config);
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


