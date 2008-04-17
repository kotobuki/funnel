/**
 * Flash a LED on change
 * 
 * Flash a LED on change of ain 0
 * ain 0�̒l���ω������Ƃ���LED����u�_��������
 * 
 * input: a photocell
 * output: LED
 */

import processing.funnel.*;

Gainer gio;
boolean changed = false;

void setup()
{
  size(200, 200);
  frameRate(30);

  gio= new Gainer(this, Gainer.MODE1);
  gio.autoUpdate = true;

  Filter filters[] = {
    new SetPoint(0.65, 0.05)
  };
  gio.analogInput(0).filters = filters;
}

void draw()
{
  if (changed) {
    gio.analogOutput(0).value = 1;
    changed = false;
  } else {
    gio.analogOutput(0).value = 0;
  }  
}

// The event handler for SetPoint filters to input ports
// (from zero to non-zero)
// SetPoint�t�B���^�K�p��̒l��0����0�ȊO�ɕω��������ɌĂ΂��C�x���g�n���h��
void risingEdge(PortEvent e)
{
  if (e.target.number == gio.analogInput[0]) {
    println("0 > 1");
    changed = true;
  }
}

// The event handler for SetPoint filters to input ports
// (from non-zero to zero)
// SetPoint�t�B���^�K�p��̒l��0����0�ȊO�ɕω��������ɌĂ΂��C�x���g�n���h��
void fallingEdge(PortEvent e)
{
  if (e.target.number == gio.analogInput[0]) {
    println("0 < 1");
    changed = true;
  }
}
