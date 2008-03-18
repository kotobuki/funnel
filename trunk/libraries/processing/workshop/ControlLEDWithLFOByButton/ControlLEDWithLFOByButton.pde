/**
 * I/Oモジュールのボタンを押すとLEDが点滅します
 * 
 * ステップ：
 * 1) I/Oモジュール上のLEDをチカチカ点滅させる
 * 2) aout 0に接続したLEDをチカチカ点滅させる
 * 3) aout 0に接続したLEDをふわふわ点滅させる
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

  Filter filters[] = {
    new SetPoint(0.5, 0.0)
  };
  gainer.analogInput(0).filters = filters;

  osc = new Osc(this, Osc.SIN, 1.0, 0);
  osc.serviceInterval = 30;
  osc.addEventListener(Osc.UPDATE, "oscUpdated");
}

void draw()
{
  background(100);
}

void oscUpdated(Osc osc)
{
  gainer.analogOutput(0).value = osc.value;
}

void risingEdge(PortEvent e)
{
  if (e.target.number == gainer.analogInput[0]) {
    osc.reset();
    osc.start();
  }
}

void fallingEdge(PortEvent e)
{
  if (e.target.number == gainer.analogInput[0]) {
    osc.stop();
  }
}
