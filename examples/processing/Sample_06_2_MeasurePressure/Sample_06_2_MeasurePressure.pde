import processing.funnel.*;

// Arduino
Arduino arduino;

// センサに接続したピン
Pin sensorPin;

// LEDに接続したピン
Pin ledPin;

void setup() {
  size(400, 200);

  // LEDに接続したピンのモードをPWMにセット
  Configuration config = Arduino.FIRMATA;
  config.setDigitalPinMode(9, Arduino.PWM);
  arduino = new Arduino(this, config);

  // センサとLEDに接続したピンを表す変数を初期化
  sensorPin = arduino.analogPin(0);
  ledPin = arduino.digitalPin(9);
}

void draw() {
  // 背景を黒で塗りつぶす
  background(0);
}

// ピンに変化が生じたら以下を実行
void change(PinEvent event) {
  // 変化が生じたピンがセンサを接続したピンであれば
  if (event.target == sensorPin) {
    // LEDの明るさとしてセンサの値をセット
    ledPin.value = sensorPin.value;
  }
}

