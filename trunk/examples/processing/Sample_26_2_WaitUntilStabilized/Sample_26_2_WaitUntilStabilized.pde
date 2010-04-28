import processing.funnel.*;

// 各状態を表す定数
final int UNKNOWN = 0;
final int BRIGHT = 1;
final int DARK = 2;

// それぞれの状態に対応した文字列
final String[] STATE_NAME = { "UNKNOWN", "BRIGHT", "DARK" };

// 状態が変化してから確定するまでに待機する時間
final int TIME_TO_WAIT = 1000;

// 閾（しきい）値とヒステリシス
final float THRESHOLD = 0.5;
final float HYSTERESIS = 0.2;

// Arduino
Arduino arduino;

// センサに接続したピン
Pin sensorPin;

// LEDに接続したピン
Pin ledPin;

// 現在と次に移行する状態
int state = UNKNOWN;
int nextState = UNKNOWN;

// 最後に変化があった時刻
int lastChange = 0;

void setup() {
  size(400, 400);

  // テキスト表示用のフォントを生成してセット
  PFont font = createFont("CourierNewPSMT", 18);
  textFont(font);

  // LEDに接続したピンのモードを出力にセット
  Configuration config = Arduino.FIRMATA;
  config.setDigitalPinMode(9, Arduino.OUT);
  arduino = new Arduino(this, config);

  // センサとLEDに接続したピンを表す変数を初期化
  sensorPin = arduino.analogPin(0);
  ledPin = arduino.digitalPin(9);

  // センサに接続したピンにSetPointフィルタをセット
  SetPoint setPoint = new SetPoint(THRESHOLD, HYSTERESIS);
  sensorPin.addFilter(setPoint);
}

void draw() {
  // 前回変化があった時刻からの経過時間を求める
  int elapsedTime = millis() - lastChange;

  // 現在の状態と次に移行する状態が異なり、
  // 変化してから一定の時間が経過していたら
  if ((state != nextState) && (elapsedTime > TIME_TO_WAIT)) {
    // 次の状態がBRIGHTであれば
    if (nextState == BRIGHT) {
      // LEDを消灯してBRIGHTに移行
      ledPin.value = 0;
    }
    // 次の状態がDARKであれば
    else if (nextState == DARK) {
      // LEDを点灯してDARKに移行
      ledPin.value = 1;
    }
    // 現在の状態を更新
    state = nextState;
  }

  // 現在の状態、次に移行する状態、経過時間を表示
  background(0);
  text("State: " + STATE_NAME[state], 10, 20);
  text("Next state: " + STATE_NAME[nextState], 10, 40);
  text("Elapsed time: " + elapsedTime, 10, 60);
}

// いずれかのピンで立ち上がりイベントが発生したら以下が呼ばれる
void risingEdge(PinEvent e) {
  // 立ち上がりイベントが発生したのがセンサに接続したピンであれば
  if (e.target == sensorPin) {
    // 次に移行する状態をBRIGHTにセットして変化した時刻をリセット
    nextState = BRIGHT;
    lastChange = millis();
  }
}

// いずれかのピンで立ち下がりイベントが発生したら以下が呼ばれる
void fallingEdge(PinEvent e) {
  // 立ち下がりイベントが発生したのがセンサに接続したピンであれば
  if (e.target == sensorPin) {
    // 次に移行する状態をDARKにセットして変化した時刻をリセット
    nextState = DARK;
    lastChange = millis();
  }
}

