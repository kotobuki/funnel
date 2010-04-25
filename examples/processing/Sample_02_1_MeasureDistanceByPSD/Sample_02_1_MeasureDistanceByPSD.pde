import processing.funnel.*;

// Arduino
Arduino arduino;

// センサに接続したピン
Pin sensorPin;

// センサの測距範囲内に対象物がないと判断する閾値
final float THRESHOLD = 0.08;

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

  if (value > THRESHOLD) {
    // 読み取った値が閾値よりも大きければ距離に変換して表示
    int range = round((6787 / (value * 1023 - 3)) - 4);
    text("Range: " + range + " cm", 10, 20);
  }
  else {
    // 読み取った値が閾値以下であれば「OFF」と表示
    text("Range: OFF", 10, 20);
  }
}

