import processing.funnel.*;

// Arduino
Arduino arduino;

// モータに接続したピン（D9）
Pin motorPin;

// モータを一定間隔で駆動するためのオシレータ
Osc osc;

// 前回トリガした時刻
int lastTrigger = 0;

void setup() {
  size(400, 400);

  // モータに接続したピンのモードを出力にセット
  Configuration config = Arduino.FIRMATA;
  config.setDigitalPinMode(9, Arduino.OUT);
  arduino = new Arduino(this, config);

  // モータに接続したピンを表す変数を初期化
  motorPin = arduino.digitalPin(9);

  // 矩形波、周波数1Hz、繰り返し回数1 のオシレータを生成
  osc = new Osc(this, Osc.SQUARE, 1, 1);

  // オシレータに対するイベントリスナをセット
  osc.addEventListener(Osc.UPDATE, "oscUpdated");
}

void draw() {
  background(100);

  // 現在の時刻を取得
  int now = millis();

  // 前回トリガしてから2000ms経過していたら以下を実行
  if ((now - lastTrigger) > 2000) {
    // オシレータをリセットした後スタートし、トリガした時刻を更新
    osc.reset();
    osc.start();
    lastTrigger = now;
  }
}

// オシレータが更新されたら以下を実行
void oscUpdated(Osc osc) {
  // モータに接続したピンの値をオシレータの値で更新
  motorPin.value = osc.value;
}

