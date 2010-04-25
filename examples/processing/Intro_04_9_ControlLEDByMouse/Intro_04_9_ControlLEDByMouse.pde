import processing.funnel.*;

// Arduino
Arduino arduino;

// LEDに接続したピンの番号
Pin ledPin;

void setup() {
  size(400, 400);

  // LEDに接続したピンのモードを出力にセット
  Configuration config = Arduino.FIRMATA;
  config.setDigitalPinMode(9, Arduino.OUT);
  arduino = new Arduino(this, config);

  // LEDに接続したピンを表す変数を初期化
  ledPin = arduino.digitalPin(9);
}

void draw() {
  background(100);
}

// マウスボタンが押されたら
void mousePressed() {
  // LEDに接続したピンの値を1にセットしてLEDを点灯
  ledPin.value = 1;
}

// マウスボタンが離されたら
void mouseReleased() {
  // LEDに接続したピンの値を0にセットしてLEDを消灯
  ledPin.value = 0;
}

