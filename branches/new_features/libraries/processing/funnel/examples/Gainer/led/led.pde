/*
Gainer
on board led
*/

import processing.funnel.*;

Gainer gainer;

void setup()
{
  size(200,200);
  
  gainer = new Gainer(this,Gainer.MODE1);
}

void draw()
{
  background(170);
  
  if(mousePressed){
    gainer.led().value = 1.0;
  }else{
    gainer.led().value = 0.0;
  }
}
  



