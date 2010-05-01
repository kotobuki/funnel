import processing.funnel.*;

// Arduino
Arduino arduino;

// センサのANピンに接続したピン
Pin sensorPin;

void setup() {
  size(400, 400);

  // 距離の表示に使用するフォントを生成
  PFont font = createFont("CourierNewPSMT", 18);
  textFont(font);

  // Arduinoのインスタンスを生成してsensorPinを初期化
  arduino = new Arduino(this, Arduino.FIRMATA);
  sensorPin = arduino.analogPin(0);
}

void draw() {
  // 背景を黒で塗りつぶす
  background(0);

  // センサの値を読み取る
  float value = sensorPin.value;

  // 読み取った値をインチ単位とセンチ単位に変換
  float rangeInInches = value * 512;
  float rangeInCentimeters = rangeInInches * 2.54;

  // 小数点以下を四捨五入して距離をそれぞれの単位で表示
  text("Range: " + round(rangeInInches) + " inch", 10, 20);
  text(" " + round(rangeInCentimeters) + " cm", 
       10, 50);
}

