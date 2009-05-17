/*
Gainer
digital out (dout0)
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
    gainer.digitalOutput(0).value = 1.0;
  }else{
     gainer.digitalOutput(0).value = 0.0;
  }
}
  



