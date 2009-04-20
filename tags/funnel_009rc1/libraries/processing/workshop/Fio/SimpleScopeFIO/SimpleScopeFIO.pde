import processing.funnel.*;

Fio fio;
PFont myFont;
Scope[] scope;

void setup()
{
  size(340, 480);
  frameRate(30);

  myFont = createFont("CourierNewPSMT", 12);
  textFont(myFont);

  int[] moduleIDs = {1};
  fio = new Fio(this, moduleIDs, Fio.FIRMATA);

  scope = new Scope[3];  
  scope[0] = new Scope(30, 35, 200, 100, "A0");
  scope[1] = new Scope(30, 185, 200, 100, "A1");
  scope[2] = new Scope(30, 335, 200, 100, "A2");
}

void draw()
{
  background(0);
  scope[0].updateAndDraw(fio.iomodule(1).analogPin(0).value);
  scope[1].updateAndDraw(fio.iomodule(1).analogPin(1).value);
  scope[2].updateAndDraw(fio.iomodule(1).analogPin(2).value);
}
