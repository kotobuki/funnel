/*
Gainer
 button event handler
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

void gainerButtonEvent(boolean bt)
{
  if(bt){
    fill(203,100,0);
  }else{
    fill(100,203,0);
  }
  println(bt);
}
  



