/*
Osc with handler

©•ª‚ÅOsc.update()‚ğŒÄ‚Ño‚µ‚Ä‚Í‚¢‚¯‚Ü‚¹‚ñ
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

}

void draw()
{
}


float oldValue;

void oscUpdated(Osc osc)
{
  float rate=150;
  line(150,rate*oldValue,150,rate*osc.value);
  //Shift screen
  for(int y=0; y<256; y++){
    for(int x=0; x<255; x++){
      color col = get(x+1,y);
      set(x,y,col);
    }
  }
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



