/*
Gainer
digital out (dout0)
*/

import processing.funnel.*;

Funnel gainer;

void setup()
{
  size(200,200);
  frameRate(25);
  
  gainer = new Funnel(this,GAINER.CONFIGURATION_1);
  gainer.autoUpdate = true;
}

void draw()
{
  background(170);
  
  if(mousePressed){
    gainer.port(GAINER.digitalOutput[0]).value = 1.0;
  }else{
     gainer.port(GAINER.digitalOutput[0]).value = 0.0;
  }
}
  



