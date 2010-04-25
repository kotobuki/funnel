import processing.funnel.*;

// 最後にセンサの反応がなくなってからのタイムアウト時間
final int TIMEOUT = 15000;

// Arduino
Arduino arduino;

// センサに接続したピン
Pin sensorPin;

// LEDに接続したピン
Pin ledPin;

// 現在アクティブであるか否か
boolean isActive = false;

// 最後にアクティブだった時刻
int lastActive = 0;

void setup() {
  size(400, 400);

  // 状態と経過時間を表示するために使用するフォントを生成
  PFont font = createFont("CourierNewPSMT", 18);
  textFont(font);

  // センサとLEDに接続したピンのモードをセット
  Configuration config = Arduino.FIRMATA;
  config.setDigitalPinMode(2, Arduino.IN);
  config.setDigitalPinMode(13, Arduino.OUT);
  arduino = new Arduino(this, config);

  // センサとLEDに接続したピンを表す変数を初期化
  sensorPin = arduino.digitalPin(2);
  ledPin = arduino.digitalPin(13);
}

void draw() {
  // 前回アクティブだった時刻からの経過時間を取得
  int elapsedTime = millis() - lastActive;

  // 現在の状態と経過時間を表示
  background(0);
  text("State: " + (isActive ? "Active" : "Inactive"),
       10, 20);
  text("Elapsed time: " + elapsedTime, 10, 50);

  // 現在非アクティブかつ経過時間がタイムアウト時間を超えていたら
  if (!isActive && (elapsedTime > TIMEOUT)) {
    // LEDを消灯
    ledPin.value = 0;
  }
}

void risingEdge(PinEvent e) {
  // 立ち上がりイベントが発生したのがセンサに接続したピンであれば
  if (e.target == sensorPin) {
    // LEDを点灯して現在の状態をアクティブにセット
    ledPin.value = 1;
    isActive = true;
  }
}

void fallingEdge(PinEvent e) {
  // 立ち下がりイベントが発生したのがセンサに接続したピンであれば
  if (e.target == sensorPin) {
    // 最後にアクティブだった時刻として現在の時刻を記録して
    // 現在の状態を非アクティブにセット
    lastActive = millis();
    isActive = false;
  }
}

