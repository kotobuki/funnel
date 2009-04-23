/*
Osc Test 1
draw()�̊Ԋu�� update()���Ăяo����Osc���A�b�v�f�[�g

���Ӂ@Osc.start()���Ȃ��Ă悢�B
Osc.stop()���Ă�update()�ōX�V�����
*/

import processing.funnel.*;

Osc osc;

void setup()
{
  size(300,300);
  frameRate(25);
  
  background(255); 
  //���� 1.0/s �� 1 time
  osc = new Osc(this,Osc.SIN,1.0,1);
  osc.reset();
  
}

void draw()
{
  translate(0,10);
  
  float oldValue = osc.value;
  osc.update();  //update wave
  float rate = 200;
  line(width/2,rate*oldValue,width/2,rate*osc.value);
    
  //shift screen
  copy(0,0,width,height,-1,0,width,height);
  
}

void mousePressed()
{
    osc.reset();
}





