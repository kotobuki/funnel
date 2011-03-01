import processing.funnel.*;

Arduino arduino;

// LEDに接続したピン
Pin ledPin;

// LEDを点滅させるためのオシレータ
Osc osc;

void setup() {
  size(200, 200);

  // LEDに接続したピンのモードを出力にセット
  Configuration config = Arduino.FIRMATA;
  config.setDigitalPinMode(13, Arduino.OUT);

  // Windowsの場合には（）内の引数を必要に応じて変更
  arduino = new Arduino(this, config);

  // LEDに接続したピンのモードを表す変数を初期化
  ledPin = arduino.digitalPin(13);

  // 周波数1Hz、矩形波のオシレータを生成してスタート
  osc = new Osc(this, Osc.SQUARE, 1.0, 0);
  osc.addEventListener(Osc.UPDATE, "oscUpdated");
  osc.start();
}

void draw() {
  background(100);
}

// オシレータが更新されたら
void oscUpdated(Osc osc) {
  // LEDに接続したピンの値をオシレータの値にセット
  ledPin.value = osc.value;
}

