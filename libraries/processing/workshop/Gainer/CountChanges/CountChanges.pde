/**
 * •Ï‰»‚ª‹N‚«‚éŠÔŠu‚ðŒv‘ª‚·‚é
 */

import processing.funnel.*;

Gainer gainer;
int count = 0;
float last = 0;

void setup()
{
  size(200, 200);
  frameRate(30);
  gainer= new Gainer(this, Gainer.MODE1);
  gainer.autoUpdate = true;

  Filter filters[] = {
    new SetPoint(0.75, 0.05)
  };
  gainer.analogInput(0).filters = filters;
  
  last = millis();
}

void draw()
{
  background(100);
}

void fallingEdge(PortEvent e)
{
  if (e.target.number == gainer.analogInput[0]) {
    float now = millis();
    count++;
    println("count: " + count + ", interval: " + (now - last));
    last = now;
  }
}
