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

  Filter filters[] = {
    new SetPoint(0.5, 0.0)
  };
  gainer.button().filters = filters;
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

/*
// changeを使った書き方
void change(PortEvent e)
{
  if (e.target.number == Gainer.button) {
    gainer.led().value = e.target.value;
    println("change: " + e.target.value);
  }
}
*/

/*
// risingEdgeとfallingEdgeを使った書き方
void risingEdge(PortEvent e)
{
  if (e.target.number == Gainer.button) {
    gainer.led().value = 1.0;
  }
}

void fallingEdge(PortEvent e)
{
  if (e.target.number == Gainer.button) {
    gainer.led().value = 0.0;
  }
}
*/
