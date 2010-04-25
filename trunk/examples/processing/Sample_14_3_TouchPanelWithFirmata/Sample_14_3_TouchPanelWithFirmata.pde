import processing.funnel.*;

Arduino arduino;

// X、Y、タッチの有無を表すピン
Pin xPin;
Pin yPin;
Pin touchPin;

// タッチしているか否か
boolean isTouched = false;

// 前回のXとY の値
float lastX = 0;
float lastY = 0;

void setup() {
  size(400, 300);

  // Arduinoのインスタンスを生成
  arduino = new Arduino(this, Arduino.FIRMATA);

  // アナログピンの0 番と1 番はXとYを表すピン
  xPin = arduino.analogPin(0);
  xPin.addFilter(new Scaler(0, 1, 0, width - 1));
  yPin = arduino.analogPin(1);
  yPin.addFilter(new Scaler(0, 1, 0, height - 1));

  // アナログピンの2 番はタッチの有無を表すピン
  touchPin = arduino.analogPin(2);
  touchPin.addFilter(new SetPoint(0.5, 0.1));

  // 背景を黒で塗りつぶして線の描画色を白にセット
  background(0);
  stroke(255);
}

void draw() {
  // もしタッチされていたら
  if (isTouched) {
    // 現在のXとY の値を求める
    float x = xPin.value;
    float y = yPin.value;

    // 前回の位置から直線を描画する
    line(lastX, lastY, x, y);

    // 前回のXとY の値として今回の値をセット
    lastX = x;
    lastY = y;
  }
}

// いずれかのピンで0から1に変化したら以下が呼ばれる
void risingEdge(PinEvent e) {
  // イベントが発生したのがタッチの有無を表すピンであれば
  if (e.target == touchPin) {
    // 背景を黒で塗りつぶしてタッチの有無を表すフラグをtrueにセット
    background(0);
    isTouched = true;
    // 前回のXとY の値として現在の値をセット
    lastX = xPin.value;
    lastY = yPin.value;
  }
}

// いずれかのピンで1から0に変化したら以下が呼ばれる
void fallingEdge(PinEvent e) {
  // イベントが発生したのがタッチの有無を表すピンであれば
  if (e.target == touchPin) {
    // タッチの有無を表すフラグをfalseにセット
    isTouched = false;
  }
}

