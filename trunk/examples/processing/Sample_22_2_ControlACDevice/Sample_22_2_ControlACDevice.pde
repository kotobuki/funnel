import processing.funnel.*;

// Arduino
Arduino arduino;

// SSRに接続したピン
Pin ssrPin;

// オシレータ
Osc osc;

void setup() {
  size(200, 200);

  // テキスト表示用のフォントを生成してセット
  PFont font = createFont("CourierNewPSMT", 18);
  textFont(font);

  // SSRに接続したピンのモードを出力にセット
  Configuration config = Arduino.FIRMATA;
  config.setDigitalPinMode(9, Arduino.OUT);
  arduino = new Arduino(this, config);

  // SSRに接続したピンを表す変数を初期化
  ssrPin = arduino.digitalPin(9);

  // 0.5Hzの周波数で矩形波を生成するオシレータを準備してスタート
  osc = new Osc(this, Osc.SQUARE, 0.5, 0);
  osc.addEventListener(Osc.UPDATE, "oscUpdated");
  osc.start();
}

void draw() {
  // 背景を黒で塗りつぶす
  background(0);

  // オシレータの状態を表示
  text("Osc: " + osc.value, 10, 20);
}

// オシレータが更新されたら以下を実行
void oscUpdated(Osc o) {
  // SSRを接続したピンの値をオシレータの値で更新
  ssrPin.value = o.value;
}

