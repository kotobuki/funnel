import ddf.minim.*;
import processing.funnel.*;

Arduino arduino;

// Minimとクリック音のサンプル
Minim minim;
AudioSample click;

// タッチセンサモジュールに接続したピン
Pin sensorPin;

void setup() {
  size(400, 400);

  // Minimのインスタンスを生成
  minim = new Minim(this);

  // クリック音のサンプルをロード
  click = minim.loadSample("click.mp3");

  // Arduinoのインスタンスを生成してsensorPinを初期化
  Configuration config = Arduino.FIRMATA;
  config.setDigitalPinMode(2, Arduino.IN);
  arduino = new Arduino(this, config);
  sensorPin = arduino.digitalPin(2);
}

void draw() {
  background(0);
}

// いずれかのピンで値が0から1に変化すると呼ばれる
void risingEdge(PinEvent e) {
  // イベントが発生したのがセンサに接続したピンであればクリック音をトリガ
  if (e.target == sensorPin) {
    click.trigger();
  }
}

// escキーを押してスケッチが終了する際に呼ばれる
void stop() {
  // Minim関連のオブジェクトの終了処理を実行
  click.close();
  minim.stop();

  // 本来の終了処理を実行
  super.stop();
}

