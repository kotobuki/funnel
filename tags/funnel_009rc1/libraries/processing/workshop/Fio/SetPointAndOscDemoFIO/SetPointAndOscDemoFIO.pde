import processing.funnel.*;

Fio fio;
Osc osc;

void setup()
{
  size(320, 240);
  frameRate(30);

  int[] moduleIDs = {1};

  // ArduinoでGainerのaoutに相当するモードはPWM
  Configuration config = Fio.FIRMATA;
  config.setDigitalPinMode(11, Fio.PWM);  

  fio = new Fio(this, moduleIDs, config);

  Filter f[] = {
    // パラメータは閾値とヒステリシス
    new SetPoint(0.5, 0.05)
  };
  fio.iomodule(1).analogPin(0).filters = f;

  // パラメータは波形、周波数、繰り返し回数（0は無制限）
  osc = new Osc(this, Osc.SIN, 0.5, 0);
  osc.serviceInterval = 40;
  osc.addEventListener(Osc.UPDATE, "oscUpdated");
}

void draw()
{
  background(100);
}

// オシレータが更新する度に呼ばれるイベントリスナ
void oscUpdated(Osc osc)
{
  fio.iomodule(1).digitalPin(11).value = osc.value;
}

// SetPointをセットした入力が0から1に変化する時に呼ばれるイベントリスナ
void risingEdge(PortEvent e)
{
  // Arduinoでピンを連番で表現する際、A0はD13の後の14番になる
  if (e.target.number == 14) {
    // 明るくなったらオシレータを停止してLEDを消灯
    println("BRIGHT");
    osc.stop();
    fio.iomodule(1).digitalPin(11).value = 0;
  }
}

// SetPointをセットした入力が1から0に変化する時に呼ばれるイベントリスナ
void fallingEdge(PortEvent e)
{
  // Arduinoでピンを連番で表現する際、A0はD13の後の14番になる
  if (e.target.number == 14) {
    // 暗くなったらオシレータを再スタート
    println("DARK");
    osc.reset();
    osc.start();
  }
}
