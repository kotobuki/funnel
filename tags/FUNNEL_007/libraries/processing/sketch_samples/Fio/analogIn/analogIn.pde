/*
Fio 
analog in
*/

import processing.funnel.*;

Fio fio;
PFont myFont;


void setup()
{
  size(400,130);
  frameRate(25);
  
  myFont = loadFont("CourierNewPSMT-24.vlw");
  textFont(myFont, 24);
  
  int[] moduleIDs = {2};
  fio = new Fio(this,moduleIDs);
 
}

void draw()
{
  background(0);
  text("analogInput[0]: " + fio.iomodule(2).port(0).value,10,80);  
}
  



