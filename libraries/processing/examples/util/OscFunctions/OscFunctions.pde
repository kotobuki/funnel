/*
Osc with handler
Osc.start()したあとは
自分でOsc.update()を呼び出してはいけません
*/

import processing.funnel.*;

Osc osc;

void setup()
{
  size(300,300);
 
  background(255); 
  frameRate(25);
    
  osc = new Osc(this,Osc.SIN,1.0,0);
  osc.serviceInterval = 30;
  osc.addEventListener(Osc.UPDATE,"oscUpdated");
  osc.start();

  smooth();
}

void draw()
{
 
}


float oldValue;

void oscUpdated(Osc osc)
{
  float rate=150;
  line(width/2,rate*oldValue,width/2,rate*osc.value);
  //shift screen
  copy(0,0,width,height,-1,0,width,height);
  
  oldValue = osc.value;
}

void mousePressed()
{
  println("osc update stop");
  osc.stop();
}
void mouseReleased()
{
  osc.start();
  println("osc update start");
}




