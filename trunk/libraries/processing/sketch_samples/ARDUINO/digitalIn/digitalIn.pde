/*
Arduino 
digital in (13pin)
*/

import processing.funnel.*;

Arduino arduino;
PFont myFont;

void setup()
{
  size(400,130);
  frameRate(25);
  
  myFont = loadFont("CourierNewPSMT-24.vlw");
  textFont(myFont, 24);
  
  arduino = new Arduino(this,Arduino.FIRMATA);
 
}

void draw()
{
  background(0);
  text("digitalInput[13]: " + arduino.digitalPin(13).value,10,80); 
}
  



