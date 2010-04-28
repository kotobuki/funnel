import processing.funnel.*;

// Arduino
Arduino arduino;

// ボタンに接続したピン
Pin buttonPin;

// 前回チャタリング除去を行った時間
int lastDebounceTime = 0;

// チャタリング除去を行う時間
int debounceDelay = 50;

// ボタンが押されたカウント
int count = 0;

void setup() {
  size(400, 400);

  // テキスト表示で使用するフォントを生成して読み込む
  PFont font = createFont("CourierNewPSMT", 18);
  textFont(font);

  // Arduinoのインスタンスを生成し、ボタンに接続したピンを表す変数を初期化
  Configuration config = Arduino.FIRMATA;
  config.setDigitalPinMode(8, Arduino.IN);
  arduino = new Arduino(this, config);
  buttonPin = arduino.digitalPin(8);
}

void draw() {
  // 背景を黒で塗りつぶして現在のカウントを表示する
  background(0);
  text("Count: " + count, 10, 20);
}

// いずれかのピンで立ち上がりイベントが発生したら以下が実行される
void risingEdge(PinEvent e) {
  // ピンの立ち上がりイベントが発生したのがボタンを接続したピンであれば
  if (e.target == buttonPin) {
    // 現在の時刻
    int now = millis();
    // 前回デバウンスを行ってから一定時間が経過していれば以下を実行
    if ((now - lastDebounceTime) > debounceDelay) {
      // カウントを1だけ増やす
      count = count + 1;
      // 前回デバウンスを行った時間として現在の時刻をセット
      lastDebounceTime = now;
    }
  }
}

