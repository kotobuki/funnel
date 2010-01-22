/*
Osc Test 1
draw()の間隔で明示的にupdate()を呼び出してOscをアップデート

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
  translate(0,10);
  
  float oldValue = osc.value;
  osc.update();
  float rate = 200;
  line(width/2,rate*oldValue,width/2,rate*osc.value);
    
  //shift screen
  copy(0,0,width,height,-1,0,width,height);
  
}

void mousePressed()
{
    osc.reset();
}






