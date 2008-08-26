/**
 * Flash a LED on change
 * 
 * Flash a LED on changes of the ain 0
 * ain 0の値が変化したときにLEDを一瞬点灯させる
 * 
 * input: a photocell (connect to the ain 0)
 * output: LED (connect to the aout 0)
 */

import processing.funnel.*;

Gainer gio;
Osc flasher;

void setup()
{
  size(200, 200);
  frameRate(30);

  gio = new Gainer(this, Gainer.MODE1);
  gio.autoUpdate = true;

  Filter filters[] = {
    new SetPoint(0.50, 0.05)
  };
  gio.analogInput(0).filters = filters;

  flasher = new Osc(this, Osc.IMPULSE, 1.0, 1);
  Osc.serviceInterval = 30;
  flasher.addEventListener(Osc.UPDATE, "oscUpdated");
}

void draw()
{

}

void oscUpdated(Osc o)
{
  gio.led().value = flasher.value;
}

// The event handler for SetPoint filters to input ports
// (from zero to non-zero)
// SetPointフィルタ適用後の値が0から0以外に変化した時に呼ばれるイベントハンドラ
void risingEdge(PortEvent e)
{
  if (e.target.number == gio.analogInput[0]) {
    println("0 to 1");
    flasher.reset();
    flasher.start();
  }
}

// The event handler for SetPoint filters to input ports
// (from non-zero to zero)
// SetPointフィルタ適用後の値が0から0以外に変化した時に呼ばれるイベントハンドラ
void fallingEdge(PortEvent e)
{
  if (e.target.number == gio.analogInput[0]) {
    println("1 to 0");
    flasher.reset();
    flasher.start();
  }
}

