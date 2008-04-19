/**
 * I/O���W���[���̃{�^����������LED���_�ł��܂�
 * 
 * �X�e�b�v�F
 * 1) I/O���W���[�����LED���`�J�`�J�_�ł�����
 * 2) aout 0�ɐڑ�����LED���`�J�`�J�_�ł�����
 * 3) aout 0�ɐڑ�����LED���ӂ�ӂ�_�ł�����
 */

import processing.funnel.*;

Gainer gainer;
Osc osc;

void setup()
{
  size(200, 200);
  frameRate(30);

  gainer= new Gainer(this, Gainer.MODE1);
  gainer.autoUpdate = true;

  osc = new Osc(this, Osc.SQUARE, 1.0, 0);
  osc.serviceInterval = 30;
  osc.addEventListener(Osc.UPDATE, "oscUpdated");
}

void draw()
{
  background(100);
}

void oscUpdated(Osc osc)
{
  gainer.led().value = osc.value;
//  gainer.analogOutput(0).value = osc.value;
}

void gainerButtonEvent(boolean pressed)
{
  if (pressed) {
    osc.reset();
    osc.start();
  } else {
    osc.stop();
  }
}
