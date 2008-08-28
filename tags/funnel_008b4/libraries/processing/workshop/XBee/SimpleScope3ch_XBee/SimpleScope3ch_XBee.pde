import processing.funnel.*;

XBee xbee;
PFont myFont;
Scope[] scope;

void setup()
{
  size(340, 480);
  frameRate(30);
  
  myFont = loadFont("CourierNewPSMT-12.vlw");
  textFont(myFont, 12);
  
  int[] moduleIDs = { 1 };
  xbee = new XBee(this, moduleIDs);

  scope = new Scope[3];  
  scope[0] = new Scope(30, 35, 200, 100, "X axis");
  scope[1] = new Scope(30, 185, 200, 100, "Y axis");
  scope[2] = new Scope(30, 335, 200, 100, "Z axis");
}

void draw()
{
  background(0);
  scope[0].updateAndDraw(xbee.iomodule(1).port(1).value);
  scope[1].updateAndDraw(xbee.iomodule(1).port(2).value);
  scope[2].updateAndDraw(xbee.iomodule(1).port(0).value);
}
