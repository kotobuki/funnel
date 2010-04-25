import processing.funnel.*;

// Arduino
Arduino arduino;

// 光センサに接続したピン
Pin sensorPin;

// LEDに接続したピン
Pin ledPin;

void setup() {
  size(400, 400);

  // LEDに接続したピンのモードをPWMにセット
  Configuration config = Arduino.FIRMATA;
  config.setDigitalPinMode(9, Arduino.PWM);
  arduino = new Arduino(this, config);

  // 光センサとLEDに接続したピンを表す変数を初期化
  sensorPin = arduino.analogPin(0);
  ledPin = arduino.digitalPin(9);

  // 光センサに接続したピンに範囲を逆転させるためのスケーラをセット
  Scaler scaler = new Scaler(0, 1, 1, 0);
  sensorPin.addFilter(scaler);
}

void draw() {
  background(100);
}

// いずれかのピンで変化が生じたら以下が呼ばれる
void change(PinEvent e) {
  // 変化が生じたのがセンサを接続したアナログピンであれば
  if (e.target == sensorPin) {
    // LEDに接続したピンの値をセンサに接続したピンの値にセットする
    ledPin.value = sensorPin.value;
  }
}

