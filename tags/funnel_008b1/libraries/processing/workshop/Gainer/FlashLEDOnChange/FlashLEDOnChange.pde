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
boolean changed = false;

void setup()
{
  size(200, 200);
  frameRate(30);

  gio = new Gainer(this, Gainer.MODE1);

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

  // NOTE: Do update manually, or a flash might be ignored depends on 
  // the timing of auto update
  // 注意：手動で更新すること。そうしないと事項更新のタイミング次第で無視されてしまう。
  gio.update();
}

// The event handler for SetPoint filters to input ports
// (from zero to non-zero)
// SetPointフィルタ適用後の値が0から0以外に変化した時に呼ばれるイベントハンドラ
void risingEdge(PortEvent e)
{
  if (e.target.number == gio.analogInput[0]) {
    println("0 > 1");
    changed = true;
  }
}

// The event handler for SetPoint filters to input ports
// (from non-zero to zero)
// SetPointフィルタ適用後の値が0から0以外に変化した時に呼ばれるイベントハンドラ
void fallingEdge(PortEvent e)
{
  if (e.target.number == gio.analogInput[0]) {
    println("0 < 1");
    changed = true;
  }
}
