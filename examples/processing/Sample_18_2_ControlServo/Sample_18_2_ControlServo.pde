import processing.funnel.*;

// Arduino
Arduino arduino;

// センサに接続したアナログピン
Pin sensorPin;

// サーボに接続したデジタルピンの番号
Pin servoPin;

void setup() {
  size(400, 200);

  // サーボに接続したピンのモードをSERVOにセット
  Configuration config = Arduino.FIRMATA;
  config.setDigitalPinMode(9, Arduino.SERVO);
  arduino = new Arduino(this, config);

  // センサとサーボに接続したピンを表す変数を初期化
  sensorPin = arduino.analogPin(0);
  servoPin = arduino.digitalPin(9);
}

void draw() {
  // 背景を黒で塗りつぶす
  background(0);
}

// ピンに変化が生じたら以下を実行
void change(PinEvent event) {
  // 変化が生じたピンがセンサに接続したピンであれば
  if (event.target == sensorPin) {
    // センサに接続したピンの値をサーボを接続したピンの値としてセットする。
    // センサに接続したピンの値は0〜1の範囲なので179をかけて0〜179に、
    // サーボの値は0～255中の0～179に対応するためmapでスケーリング
    float angle
      = map(sensorPin.value * 179, 0, 255, 0, 1);
    servoPin.value = angle;
  }
}

