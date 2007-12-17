/*
Osc Test 2
draw()の間隔で update()を呼び出してOscをアップデート

注意　Osc.stop()してもupdate()で更新される
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
  osc.start();
  
}

void draw()
{
  float oldValue = osc.value;
  osc.update();  //update wave
  float rate = 150;
  line(150,rate*oldValue,150,rate*osc.value);
    
  //Shift screen
  for(int y=0; y<256; y++){
    for(int x=0; x<255; x++){
      color col = get(x+1,y);
      set(x,y,col);
    }
  }
  
}

void mousePressed()
{
    osc.reset();
}





