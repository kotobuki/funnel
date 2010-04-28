import processing.funnel.*;

// 独立したPWMピンを用いないTA7291Pの場合にはfalseにする
final boolean useSeparatePWMPin = true;

Arduino arduino;

// IN1、IN2、PWMに接続したピン
Pin in1Pin;
Pin in2Pin;
Pin pwmPin;

// 最後に状態を変更した時刻
int lastChange = 0;

// 現在の状態
int state = -1;

// 順方向に回転

void forward(float value) {
  if (useSeparatePWMPin) {
    // 独立したPWMピンを用いる場合
    in1Pin.value = 1;
    in2Pin.value = 0;
    pwmPin.value = value;
  }
  else {
    // 独立したPWMピンを用いない場合
    in1Pin.value = value;
    in2Pin.value = 0;
  }
}

// 逆方向に回転
void reverse(float value) {
  if (useSeparatePWMPin) {
    // 独立したPWMピンを用いる場合
    in1Pin.value = 0;
    in2Pin.value = 1;
    pwmPin.value = value;
  }
  else {
    // 独立したPWMピンを用いない場合
    in1Pin.value = 0;
    in2Pin.value = value;
  }
}

// 回転を停止
void despin(boolean useBrake) {
  if (useBrake) {
    // ブレーキあり
    in1Pin.value = 1;
    in2Pin.value = 1;
    pwmPin.value = 1;
  }
  else {
    // ブレーキなし
    in1Pin.value = 0;
    in2Pin.value = 0;
    pwmPin.value = 0;
  }
}

void setup() {
  size(400, 400);

  // テキスト表示で使用するフォントを生成
  PFont font = createFont("CourierNewPSMT", 18);
  textFont(font);

  // IN1、IN2、PWMに接続したピンのモードをセット
  Configuration config = Arduino.FIRMATA;
  config.setDigitalPinMode(9, Arduino.PWM);
  config.setDigitalPinMode(10, Arduino.PWM);
  config.setDigitalPinMode(11, Arduino.PWM);
  arduino = new Arduino(this, config);

  // IN1、IN2、PWMに接続したピンを表す変数を初期化
  in1Pin = arduino.digitalPin(9);
  in2Pin = arduino.digitalPin(10);
  pwmPin = arduino.digitalPin(11);
}

void draw() {
  // 現在の時刻を取得
  int now = millis();

  // 前回状態を変更してから500ms経過していたら以下を実行
  if ((now - lastChange) > 500) {
    // 状態を次に進める（0から3 の間で繰り返す）
    state = (state + 1) % 4;

    // 状態に応じて以下を実行
    switch (state) {
    case 0: // 順方向に回転
      forward(0.3);
      background(0);
      text("Forward", 10, 20);
      break;
    case 1: // 回転を停止（ブレーキあり）
      despin(true);
      background(0);
      text("Despin (with brake)", 10, 20);
      break;
    case 2: // 逆方向に回転
      reverse(0.3);
      background(0);
      text("Reverse", 10, 20);
      break;
    case 3: // 回転を停止（ブレーキなし）
      despin(false);
      background(0);
      text("Despin (without brake)", 10, 20);
      break;
    }

    // 前回状態を変更した時刻を更新
    lastChange = now;
  }
}

// escキーを押して実行を停止した時に以下を実行
void stop() {
  // 回転を停止（ブレーキなし）
  despin(false);

  // 元々の終了処理を行う
  super.stop();
}

