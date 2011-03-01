/*
Osc Test2
*/

import processing.funnel.*;

Osc osc;

void setup()
{
  size(300,300);
  frameRate(25);
  
  background(255); 
  //周期 2.0/s : 回数 forever
  osc = new Osc(this,Osc.SQUARE,1.0,0);
  osc.reset();
}

void draw()
{
  translate(0,10);
  
  float oldValue = osc.value;
  osc.update();
  float rate = 150;
  line(width/2,rate*oldValue,width/2,rate*osc.value);

  //shift screen
  copy(0,0,width,height,-1,0,width,height);
  
}

void mousePressed()
{
    osc.reset();
}






