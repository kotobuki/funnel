/**
 * Control the LED by the button on your Gainer I/O module
 * 
 * Click on the window to turn on the LED
 * ウィンドウ上でクリックするとLEDが点灯します
 */

import processing.funnel.*;

Gainer gainer;

void setup()
{
  size(200, 200);
  frameRate(30);
  gainer= new Gainer(this, Gainer.MODE1);
  gainer.autoUpdate = true;
}

void draw()
{
  background(100);
}

void mousePressed()
{
  gainer.led().value = 1.0;
}

void mouseReleased()
{
  gainer.led().value = 0.0;
}
