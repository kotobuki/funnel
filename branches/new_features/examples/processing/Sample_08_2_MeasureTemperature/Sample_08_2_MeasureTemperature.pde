import processing.funnel.*;

// Arduino
Arduino arduino;

// センサに接続したピン
Pin sensorPin;

// 温度
float temperature = 0;

void setup() {
  size(400, 200);

  // テキストフォントを生成してセット
  PFont font = createFont("CourierNewPSMT", 24);
  textFont(font);

  // Arduinoを準備してセンサに接続したピンを表す変数を初期化
  arduino = new Arduino(this, Arduino.FIRMATA);
  sensorPin = arduino.analogPin(0);

  // センサに接続したピンにスケーラをセット
  Scaler scaler = new Scaler(0, 0.2, 0, 100);
  sensorPin.addFilter(scaler);
}

void draw() {
  // 温度をウィンドウ上に表示
  background(0);
  text("Temperature: " + temperature, 20, 20);
}

// ピンの値に変化が生じると以下を実行
void change(PinEvent event) {
  // 変化が起きたピンがセンサを接続したピンであれば
  if (event.target == sensorPin) {
    // 温度にピンの値を代入
    temperature = sensorPin.value;
  }
}

