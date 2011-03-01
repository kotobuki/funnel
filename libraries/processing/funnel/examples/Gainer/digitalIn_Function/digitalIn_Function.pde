/*
Gainer
 din has SetPoint filter from start.
 */

import processing.funnel.*;

Gainer gainer;

void setup()
{
  size(200,200);
  smooth();

  gainer = new Gainer(this,Gainer.MODE1);
}

void draw()
{
  background(230);
  ellipse(width/2,height/2,40,40);
}

void risingEdge(PinEvent e)
{
  if(e.target == gainer.digitalInput(0)){
    fill(250,204,0);
  }
}

void fallingEdge(PinEvent e)
{
  if(e.target == gainer.digitalInput(0)){
    fill(170);
  }
}


