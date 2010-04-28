import processing.funnel.*;

// Arduino
Arduino arduino;

// センサに接続したピン
Pin sensorPin;

// LEDに接続したピン
Pin ledPin;

void setup() {
  size(400, 200);

  // LEDを接続したピンのモードを出力にセット
  Configuration config = Arduino.FIRMATA;
  config.setDigitalPinMode(9, Arduino.OUT);
  arduino = new Arduino(this, config);

  // センサとLEDに接続したピンを表す変数を初期化
  sensorPin = arduino.analogPin(0);
  ledPin = arduino.digitalPin(9);

  // センサを接続したピンにSetPointフィルタをセット
  // 反応が鈍い（あるい鋭すぎる）場合はこの値を調整する
  sensorPin.addFilter(new SetPoint(0.5, 0.1));
}

void draw() {
  // 背景を黒で塗りつぶす
  background(0);
}

// SetPointフィルタをセットしたピンで0から0以外への変化が起きたら以下を実行
void risingEdge(PinEvent event) {
  // 変化が起きたピンがセンサを接続したピンであればLEDを点灯
  if (event.target == sensorPin) {
    ledPin.value = 1;
  }
}

// SetPointフィルタをセットしたピンで0以外から0への変化が起きたら以下を実行
void fallingEdge(PinEvent event) {
  // 変化が起きたピンがセンサを接続したピンであればLEDを消灯
  if (event.target == sensorPin) {
    ledPin.value = 0;
  }
}

