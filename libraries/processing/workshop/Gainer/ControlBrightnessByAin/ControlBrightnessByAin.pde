/**
 * Control brightness by an analog input device
 * 
 * Control the brightness of the background according to the value of the 
 * analog input 0
 * ain 0�̒l�ɉ����Ĕw�i�̖��邳��ω�������
 * 
 * input: a photocell or a potentiometer
 * output: screen
 */

import processing.funnel.*;

Gainer gio;
Osc osc;

void setup()
{
  size(200, 200);
  frameRate(30);

  gio= new Gainer(this, Gainer.MODE1);
  gio.autoUpdate = true;

  // Uncomment the following section to set a SetPoint filter
  // SetPoint�t�B���^���Z�b�g����ɂ͎��̃p�[�g���R�����g������
/*
  Filter filters[] = {
    // �������l��0.5�A�q�X�e���V�X��0.1
    new SetPoint(0.5, 0.1)
  };
  gio.analogInput(0).filters = filters;
*/
}

void draw()
{
  // ain 0�̒l�ɉ����Ĕw�i�̖��邳��ω�������
  background(255 * gio.analogInput(0).value);
}
