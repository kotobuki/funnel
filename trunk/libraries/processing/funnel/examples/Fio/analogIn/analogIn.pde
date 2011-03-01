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
  
  myFont = loadFont("CourierNewPSMT-24.vlw");
  textFont(myFont, 24);

  int[] moduleIDs = {1};
  fio = new Fio(this,moduleIDs,Fio.FIRMATA);
}

void draw()
{
  background(0);
  text("analogInput[0]: " + fio.iomodule(1).analogPin(0).value,10,80);  
}
  



