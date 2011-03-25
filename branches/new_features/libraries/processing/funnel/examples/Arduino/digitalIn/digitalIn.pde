/*
Arduino 
digital in (digital 13pin)
*/

import processing.funnel.*;

Arduino arduino;
PFont myFont;

int dinPin = 13;

void setup()
{
  size(400,130);
  frameRate(25);
  
  myFont = loadFont("CourierNewPSMT-24.vlw");
  textFont(myFont, 24);
  
  Configuration config = Arduino.FIRMATA;
  config.setDigitalPinMode(dinPin,Arduino.IN);
  
  arduino = new Arduino(this,config);
 
}

void draw()
{
  background(0);
  text("digitalInput["+dinPin+"]: " + arduino.digitalPin(dinPin).value,10,80); 
}
  



