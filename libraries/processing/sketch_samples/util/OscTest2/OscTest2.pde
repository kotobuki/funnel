/*
Osc Test 2
draw()�̊Ԋu�� update()���Ăяo����Osc���A�b�v�f�[�g

���Ӂ@Osc.stop()���Ă�update()�ōX�V�����
*/

import processing.funnel.*;

Osc osc;

void setup()
{
  size(300,300);
  frameRate(25);
  
  background(255); 
  //���� 2.0/s : �� forever
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





