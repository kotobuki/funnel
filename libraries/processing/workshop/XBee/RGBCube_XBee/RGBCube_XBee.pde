import processing.funnel.*;

/**
 * RGB Cube.
 * 
 * The three primary colors of the additive color model are red, green, and blue.
 * This RGB color cube displays smooth transitions between these colors. 
 */

/**
 * NOTE:
 * Modified from the original to control Z and X axis by a mouse.
 * Replace the mouseX and mouseY by a physical controller.
 * 
 * Processing�ɂ��Ă���T���v��RGBCube���}�E�X�ŃR���g���[���ł���悤��
 * �������̂�����ɕύX����XBee�ɐڑ����������x�Z���T�ŃR���g���[���ł���
 * �悤�ɂ����T���v���B
 */

XBee xbee;

void setup() 
{ 
  size(400, 400, P3D);
  frameRate(10);
  noStroke(); 
  colorMode(RGB, 1); 

  int ids[] = { 1 };
  xbee = new XBee(this, ids);

  // �����x�Z���T�̒l�ɑ΂��Ĉȉ���2�̃t�B���^���Z�b�g
  // 1) �X���[�W���O�i�ړ����ρj
  // 2) �X�P�[�����O
  Filter f0[] = {
    new Convolution(Convolution.MOVING_AVERAGE),
    new Scaler(0.30, 0.70, -1.0, 1.0, Scaler.LINEAR, true)
  };
  Filter f1[] = {
    new Convolution(Convolution.MOVING_AVERAGE),
    new Scaler(0.30, 0.70, -1.0, 1.0, Scaler.LINEAR, true)
  };
  xbee.iomodule(1).port(1).filters = f0;
  xbee.iomodule(1).port(2).filters = f1;
} 
 
void draw() 
{ 
  background(0.5, 0.5, 0.45);
  
  pushMatrix();
 
  translate(width/2, height/2, -30); 

  rotateZ(-asin(xbee.iomodule(1).port(1).value));
  rotateX(asin(xbee.iomodule(1).port(2).value));
  
  scale(100);
  beginShape(QUADS);

  fill(0, 1, 1); vertex(-1,  1,  1);
  fill(1, 1, 1); vertex( 1,  1,  1);
  fill(1, 0, 1); vertex( 1, -1,  1);
  fill(0, 0, 1); vertex(-1, -1,  1);

  fill(1, 1, 1); vertex( 1,  1,  1);
  fill(1, 1, 0); vertex( 1,  1, -1);
  fill(1, 0, 0); vertex( 1, -1, -1);
  fill(1, 0, 1); vertex( 1, -1,  1);

  fill(1, 1, 0); vertex( 1,  1, -1);
  fill(0, 1, 0); vertex(-1,  1, -1);
  fill(0, 0, 0); vertex(-1, -1, -1);
  fill(1, 0, 0); vertex( 1, -1, -1);

  fill(0, 1, 0); vertex(-1,  1, -1);
  fill(0, 1, 1); vertex(-1,  1,  1);
  fill(0, 0, 1); vertex(-1, -1,  1);
  fill(0, 0, 0); vertex(-1, -1, -1);

  fill(0, 1, 0); vertex(-1,  1, -1);
  fill(1, 1, 0); vertex( 1,  1, -1);
  fill(1, 1, 1); vertex( 1,  1,  1);
  fill(0, 1, 1); vertex(-1,  1,  1);

  fill(0, 0, 0); vertex(-1, -1, -1);
  fill(1, 0, 0); vertex( 1, -1, -1);
  fill(1, 0, 1); vertex( 1, -1,  1);
  fill(0, 0, 1); vertex(-1, -1,  1);

  endShape();
  
  popMatrix(); 
} 
