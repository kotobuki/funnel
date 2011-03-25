import processing.funnel.*;

Arduino arduino;

// 可変抵抗器に接続したピン
Pin sensorPin;

// LEDに接続したピン
Pin ledPin;

// スケッチの動作開始時に1 回だけ実行される
void setup() {
  size(400, 400);

  // LEDに接続したピンのモードをPWMにセット
  Configuration config = Arduino.FIRMATA;
  config.setDigitalPinMode(9, Arduino.PWM);
  arduino = new Arduino(this, config);

  // 可変抵抗器とLEDに接続したピンを表す変数を初期化
  sensorPin = arduino.analogPin(0);
  ledPin = arduino.digitalPin(9);
}

// スケッチの実行を終了するまで繰り返し実行される
void draw() {
  background(100);
}

// いずれかのピンで変化が生じたら以下が呼ばれる
void change(PinEvent event) {
  // 変化が生じたのが可変抵抗器に接続したアナログピンであれば
  if (event.target == sensorPin) {
    // LEDに接続したピンの値を可変抵抗器に接続したピンの値にセットする
    ledPin.value = sensorPin.value;
  }
}

