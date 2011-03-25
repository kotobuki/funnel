/*
Arduino 
analog in
*/

import processing.funnel.*;

Arduino arduino;
PFont myFont;

void setup()
{
  size(400,330);

  myFont = loadFont("CourierNewPSMT-24.vlw");
  textFont(myFont, 24);

  arduino = new Arduino(this,Arduino.FIRMATA);
 
}

void draw()
{
  background(0);

  text("analogInput[0]: " + arduino.analogPin(0).value,10,80); 
  text("analogInput[1]: " + arduino.analogPin(1).value,10,110);
  text("analogInput[2]: " + arduino.analogPin(2).value,10,140);
  text("analogInput[3]: " + arduino.analogPin(3).value,10,170);
  text("analogInput[4]: " + arduino.analogPin(4).value,10,200);
  text("analogInput[5]: " + arduino.analogPin(5).value,10,230);
  
}
  



