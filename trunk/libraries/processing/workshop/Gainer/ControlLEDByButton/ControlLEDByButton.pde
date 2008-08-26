/**
 * Control the LED by the button on your Gainer I/O module
 * 
 * Press the button on the I/O module to turn on the LED
 * I/Oモジュールのボタンを押すとLEDが点灯します
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

void gainerButtonEvent(boolean pressed)
{
  if (pressed) {
    gainer.led().value = 1.0;
  } else {
    gainer.led().value = 0.0;
  }
}

