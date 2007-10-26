/*
ARDUINO 
analog in
*/

import processing.funnel.*;

Funnel arduino;
PFont myFont;

void setup()
{
  size(400,330);
  frameRate(25);
  
  myFont = loadFont("CourierNewPSMT-24.vlw");
  textFont(myFont, 24);
  
  arduino = new Funnel(this,ARDUINO.FIRMATA);
 
}

void draw()
{
  background(0);
  text("analogInput[0]: " + arduino.port(ARDUINO.analogInput[0]).value,10,80); 
  text("analogInput[1]: " + arduino.port(ARDUINO.analogInput[1]).value,10,110);
  text("analogInput[2]: " + arduino.port(ARDUINO.analogInput[2]).value,10,140);
  text("analogInput[3]: " + arduino.port(ARDUINO.analogInput[3]).value,10,170);
  text("analogInput[4]: " + arduino.port(ARDUINO.analogInput[4]).value,10,200);
  text("analogInput[5]: " + arduino.port(ARDUINO.analogInput[5]).value,10,230);  
}
  



