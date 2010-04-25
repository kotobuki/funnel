import processing.funnel.*;

// SoftPotを押さえている状態の最小値と最大値
final float MINIMUM = 0.1;
final float MAXIMUM = 0.9;

// SoftPotを離していると判断するための閾値
final float THRESHOLD = 0.05;

Arduino arduino;

// SoftPotに接続したアナログピン
Pin sensorPin;

// LEDに接続したピン
Pin ledPin;

// 前回押されていたかどうかを保持する値
boolean wasPressed = false;

void setup() {
  size(400, 400);

  // テキスト表示に使用するフォントを用意
  PFont font = createFont("CourierNewPSMT", 18);
  textFont(font);

  // LEDに接続したピンのモードを出力にセットして
  Configuration config = Arduino.FIRMATA;
  config.setDigitalPinMode(13, Arduino.OUT);
  arduino = new Arduino(this, Arduino.FIRMATA);

  // SoftPotとLEDに接続したピンを表す変数を初期化
  sensorPin = arduino.analogPin(0);
  ledPin = arduino.digitalPin(13);

  // 画面を初期化
  background(0);
  text("Position: OFF", 10, 20);
}

void draw() {
  // センサに接続したピンの値を読み取る
  float value = sensorPin.value;

  // 現在押されているかどうかのフラグ
  boolean isPressed = wasPressed;

  // 閾値と最小値を元に現在押されているかどうかを判定
  if (value < THRESHOLD) {
    isPressed = false;
  }
  else if (value >= MINIMUM) {
    isPressed = true;
  }

  // 最小値と最大値から現在押されている位置を求める
  // 今回使用したSoftPotの範囲は50mmであるためミリ単位に変換
  float position = map(value, MINIMUM, MAXIMUM, 0, 50);

  // 前回押されていたかどうかと今回押されていたかどうかで変化を検出
  if (!wasPressed && isPressed) {
    onPress(round(position));
  }
  else if (wasPressed && !isPressed) {
    onRelease();
  }
  else if (wasPressed && isPressed) {
    onDrag(round(position));
  }

  // 次回のループ時に使用する値として現在の状態をセット
  wasPressed = isPressed;
}

// SoftPotを押されたら以下を実行
void onPress(int position) {
  // LEDを点灯して表示を更新
  ledPin.value = 1;
  background(0);
  text("Position" + position + " mm", 10, 20);
}

// SoftPotから離されたら以下を実行
void onRelease() {
  // LEDを消灯して表示を更新
  ledPin.value = 0;
  background(0);
  text("Position: OFF", 10, 20);
}

// SoftPot上でドラッグしたら以下を実行
void onDrag(int position) {
  // 表示を更新
  background(0);
  text("Position: " + position + " mm", 10, 20);
}

