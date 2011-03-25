import processing.funnel.*;

// Arduino
Arduino arduino;

// 曲げセンサに接続したピン
Pin sensorPin;

void setup() {
  size(400, 400);

  // テキスト表示で使用するフォントを生成して読み込む
  PFont font = createFont("CourierNewPSMT", 18);
  textFont(font);

  // Arduinoのインスタンスを生成してsensorPinを初期化
  arduino = new Arduino(this, Arduino.FIRMATA);
  sensorPin = arduino.analogPin(0);
}

void draw() {
  // 背景を黒で塗りつぶす
  background(0);

  // センサに接続したピンの現在の値、最大値、最小値を表示
  text("value : " + sensorPin.value, 10, 20);
  text("maximum: " + sensorPin.maximum, 10, 40);
  text("minimum: " + sensorPin.minimum, 10, 60);
}

