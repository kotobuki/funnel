/*
Arduino 
digital in (digital 13pin)
*/

import processing.funnel.*;

Arduino arduino;
PFont myFont;

int ledPin = 13;

void setup()
{
  size(400,130);
  frameRate(25);
  
  myFont = loadFont("CourierNewPSMT-24.vlw");
  textFont(myFont, 24);
  
  Configuration config = Arduino.FIRMATA;
  config.setDigitalPinMode(ledPin,Arduino.IN);
  
  arduino = new Arduino(this,config);
 
}

void draw()
{
  background(0);
  text("digitalInput[13]: " + arduino.digitalPin(13).value,10,80); 
}
  



