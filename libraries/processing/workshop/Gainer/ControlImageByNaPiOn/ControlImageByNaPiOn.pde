/**
 * din 0に接続した焦電センサの出力で静止画をコントロールします
 */

import processing.funnel.*;

final int fadeFrames = 60;

Gainer gainer;
PImage img;
int elapsedTime = 0;
boolean playing = false;
float x, y;

void setup()
{
  size(200, 200);
  background(0);
  frameRate(30);

  gainer= new Gainer(this, Gainer.MODE1);
  gainer.autoUpdate = true;

  Filter filters[] = {
    new SetPoint(0.5, 0.0)
  };
  gainer.digitalInput(0).filters = filters;

  img = loadImage("arch.jpg");
}

void draw()
{
  background(0);

  if (!playing) {
    return;
  }

  tint(255, lerp(255, 0, (float)elapsedTime/(float)fadeFrames));
  image(img, x, y);

  elapsedTime = elapsedTime + 1;
  if (elapsedTime >= fadeFrames) {
    playing = false;
    println("FINISHED!");
  }
}

void risingEdge(PortEvent e)
{
  if (e.target.number == gainer.digitalInput[0]) {
    gainer.led().value = 1.0;

    if (!playing) {
      x = random(20, (int)width - 20);
      y = random(20, (int)height - 20);
      playing = true;
      elapsedTime = 0;
      println("START!");
    }
  }
}

void fallingEdge(PortEvent e)
{
  if (e.target.number == gainer.digitalInput[0]) {
    gainer.led().value = 0.0;
  }
}
