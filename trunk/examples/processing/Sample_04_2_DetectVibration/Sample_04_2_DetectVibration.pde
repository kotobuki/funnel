import processing.funnel.*;

// Arduino
Arduino arduino;

// ピエゾ素子に接続したピン
Pin sensorPin;

// LEDに接続したピン
Pin ledPin;

void setup() {
  size(400, 400);

  // LEDに接続したピンのモードを出力にセット
  Configuration config = Arduino.FIRMATA;
  config.setDigitalPinMode(13, Arduino.OUT);

  // 2番目の引数でサンプリング間隔を10msにセット
  arduino = new Arduino(this, 10, config);

  // ピエゾ素子とLEDに接続したピンを表す変数を初期化
  sensorPin = arduino.analogPin(0);
  ledPin = arduino.digitalPin(13);

  // センサに接続したピンにSetPointフィルタをセット
  sensorPin.addFilter(new SetPoint(0.2, 0.05));
}

void draw() {
  background(100);
}

// いずれかのピンで立ち上がりイベントが発生したら以下が実行される
void risingEdge(PinEvent e) {
  // ピンの立ち上がりイベントが発生したのがセンサに接続したピンであれば
  if (e.target == sensorPin) {
    // LEDを200ms間点灯する
    ledPin.value = 1;
    delay(200);
    ledPin.value = 0;
  }
}

