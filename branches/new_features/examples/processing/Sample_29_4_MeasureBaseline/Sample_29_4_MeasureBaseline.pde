import processing.funnel.*;

// 動作状態を表す定数
final int CALIBRATING = 0;
final int RUNNING = 1;

// Arduino
Arduino arduino;

// センサに接続したピン
Pin sensorPin;

// LEDに接続したピン
Pin ledPin;

// Arduinoの準備ができて動作を開始した時刻
int start = 0;

// 現在の状態
int state = CALIBRATING;

void setup() {
  size(400, 400);

  // 表示に使用するフォントを準備
  PFont font = createFont("CourierNewPSMT", 18);
  textFont(font);

  // LEDを接続したピンのモードを出力にセット
  Configuration config = Arduino.FIRMATA;
  config.setDigitalPinMode(13, Arduino.OUT);
  arduino = new Arduino(this, config);

  // センサとLEDに接続したピンを表す変数を初期化
  sensorPin = arduino.analogPin(0);
  ledPin = arduino.digitalPin(13);

  // Arduinoの準備ができて動作を開始した時刻をセット
  start = millis();
}

void draw() {
  // 背景を黒で塗りつぶす
  background(0);

  // 現在の状態がキャリブレーション中であれば
  if (state == CALIBRATING) {
    // キャリブレーション中であることを表示
    text("Calibrating", 10, 20);

    // 動作開始から5000msが経過したら以下を実行
    if ((millis() - start) > 5000) {
      // センサの平均値を読み取る
      float average = sensorPin.average;
      println("average: " + average);

      // 平均値から閾値とヒステリシスを決定
      float threshold = average * 0.9;
      float hysteresis = 0;
      if (threshold > 0.5) {
        hysteresis = (1 - threshold) * 0.1;
      }
      else {
        hysteresis = threshold * 0.1;
      }
      println("threshold: " + threshold);
      println("hysteresis: " + hysteresis);

      // 閾値とヒステリシスもとにSetPointフィルタを生成してセット
      SetPoint setPoint = new SetPoint(threshold,
                                       hysteresis);
      sensorPin.addFilter(setPoint);

      // 現在の状態を通常動作中に移行
      state = RUNNING;
    }
  }

  // 現在の状態が通常動作中であれば
  else {
    // 通常動作中であることとセンサの値を表示
    text("Running", 10, 20);
    text("Sensor: " + sensorPin.value, 10, 40);
  }
}

// 明るくなったらLEDを消灯
void risingEdge(PinEvent e) {
  if (e.target == sensorPin) {
    ledPin.value = 0;
  }
}

// 暗くなったらLEDを点灯
void fallingEdge(PinEvent e) {
  if (e.target == sensorPin) {
    ledPin.value = 1;
  }
}

