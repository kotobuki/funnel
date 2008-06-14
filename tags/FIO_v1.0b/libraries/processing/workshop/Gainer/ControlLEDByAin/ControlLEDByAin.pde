/**
 * Control a LED by an analog input device
 * 
 * Control the brightness of the background according to the value of the 
 * analog input 0
 * ain 0の値に応じて背景の明るさを変化させる
 * 
 * input: a photocell or a potentiometer
 * output: LED
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
  // SetPointフィルタをセットするには次のパートを非コメント化する
/*
  Filter filters[] = {
    // しきい値が0.5、ヒステリシスが0.1
    new SetPoint(0.5, 0.1)
  };
  gio.analogInput(0).filters = filters;
*/
}

void draw()
{
  // ain 0の値に応じて背景の明るさを変化させる
  background(255 * gio.analogInput(0).value);
  
  // ain 0の値に応じてaout 0の値を変化させる
  // 練習：周囲が暗ければLEDを明るく、明るければLEDを暗くするにはどうすればよいか？
  gio.analogOutput(0).value = gio.analogInput(0).value;
}
