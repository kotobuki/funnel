/*
Osc Test 1
draw()の間隔で update()を呼び出してOscをアップデート

注意　Osc.start()しなくてよい。
Osc.stop()してもupdate()で更新される
*/

import processing.funnel.*;

Osc osc;

void setup()
{
  size(300,300);
  frameRate(25);
  
  background(255); 
  //周期 1.0/s 回数 1 time
  osc = new Osc(this,Osc.SIN,1.0,1);
  osc.reset();
  
}

void draw()
{
  float oldValue = osc.value;
  osc.update();  //update wave
  float rate = 200;
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





