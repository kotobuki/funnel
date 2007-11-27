/*
Gainer
digital out (dout0)
*/

import processing.funnel.*;

GAINER gainer;

void setup()
{
  size(200,200);
  frameRate(25);
  
  gainer = new GAINER(this,GAINER.CONFIGURATION_1);
  gainer.autoUpdate = true;
}

void draw()
{
  background(170);
  
  if(mousePressed){
    gainer.digitalOutput(0).value = 1.0;
  }else{
     gainer.digitalOutput(0).value = 0.0;
  }
}
  



