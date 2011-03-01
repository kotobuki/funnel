/*
Gainer
 simple read din0
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
  if(gainer.digitalInput(0).value==1.0){
    background(250,204,0);
  }else{
    background(170);
  }
}

