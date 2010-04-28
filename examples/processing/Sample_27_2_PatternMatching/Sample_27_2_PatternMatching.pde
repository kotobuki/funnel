import ddf.minim.*;
import ddf.minim.signals.*;
import processing.funnel.*;

// オカリナの穴の代わりのスイッチの状態とデジタル入力の状態の対応
final int OPENED = 0;
final int CLOSED = 1;

// 指使いとパターンの対応表
final int FINGERING_TABLE[][] = {
  { CLOSED, CLOSED, CLOSED, CLOSED },
  { CLOSED, OPENED, CLOSED, CLOSED },
  { CLOSED, CLOSED, CLOSED, OPENED },
  { CLOSED, OPENED, CLOSED, CLOSED },
  { OPENED, OPENED, CLOSED, CLOSED },
  { OPENED, OPENED, CLOSED, OPENED },
  { OPENED, CLOSED, OPENED, OPENED },
  { OPENED, OPENED, OPENED, OPENED }
};

// パターンが見つからなかった時を表す値
final int NOT_FOUND = -1;

// パターンと周波数の対応
final float FREQUENCY[] = {
  261.6, // C4
  293.7, // D4
  329.6, // E4
  349.2, // F4
  392.0, // G4
  440.0, // A4
  493.9, // B4
  523.3 // C5
};

// パターンに対応した音名
final String NOTE_NAME[] = {
  "C4", "D4", "E4", "F4", "G4", "A4", "B4", "C5"
};

// Arduino
Arduino arduino;

// タクトスイッチに接続したピン
Pin button0Pin;
Pin button1Pin;
Pin button2Pin;
Pin button3Pin;

// 感圧センサに接続したアナログピン
Pin sensorPin;

// 現在のタクトスイッチの状態を収める配列
int buttonState[] = {
  OPENED, OPENED, OPENED, OPENED
};

// Minimオブジェクト
Minim minim;

// AudioOutputオブジェクト
AudioOutput out;

// サイン波を生成するオブジェクト
SineWave sine;

void setup() {
  size(400, 400);

  // テキスト表示に使用するフォントを生成
  PFont font = createFont("CourierNewPSMT", 18);
  textFont(font);

  // タクトスイッチに接続したピンのモードを入力にセット
  Configuration config = Arduino.FIRMATA;
  config.setDigitalPinMode(2, Arduino.IN);
  config.setDigitalPinMode(3, Arduino.IN);
  config.setDigitalPinMode(4, Arduino.IN);
  config.setDigitalPinMode(5, Arduino.IN);
  arduino = new Arduino(this, Arduino.FIRMATA);

  // 各タクトスイッチを表す変数を初期化
  button0Pin = arduino.digitalPin(2);
  button1Pin = arduino.digitalPin(3);
  button2Pin = arduino.digitalPin(4);
  button3Pin = arduino.digitalPin(5);

  // 感圧センサに接続したピンを表す変数を初期化してフィルタをセット
  sensorPin = arduino.analogPin(0);
  sensorPin.addFilter(new SetPoint(0.2, 0.05));

  // Minimのインスタンスを生成
  minim = new Minim(this);

  // オーディオ出力をセット
  out = minim.getLineOut(Minim.STEREO);

  // サイン波の生成を開始してオーディオ出力に対してセット
  sine = new SineWave(0, 0, out.sampleRate());
  out.addSignal(sine);
}

void draw() {
  background(0);

  // タクトスイッチの状態を読み取る
  buttonState[0] = (button0Pin.value == 0) ? OPENED : CLOSED;
  buttonState[1] = (button1Pin.value == 0) ? OPENED : CLOSED;
  buttonState[2] = (button2Pin.value == 0) ? OPENED : CLOSED;
  buttonState[3] = (button3Pin.value == 0) ? OPENED : CLOSED;

  // 現在のスイッチの状態に対応したパターンを検索
  int index = findPattern(buttonState);

  // 検索した結果を表示
  if (index != NOT_FOUND) {
    text("Index: " + NOTE_NAME[index], 10, 20);
  }
  else {
    text("Index: Not found", 10, 20);
  }

  // パターンが見つかったら
  if (index != NOT_FOUND) {
    // サイン波の周波数をパターンに対応したものにセット
    sine.setFreq(FREQUENCY[index]);
  }
}

// いずれかのピンで値が0から1に変化したら呼ばれる
void risingEdge(PinEvent e) {
  // イベントが発生したのが感圧センサに接続したピンであれば
  if (e.target == sensorPin) {
    // サイン波の振幅を0.5にセット
    sine.setAmp(0.5);
  }
}

// いずれかのピンで値が1から0に変化したら呼ばれる
void fallingEdge(PinEvent e) {
  // イベントが発生したのが感圧センサに接続したピンであれば
  if (e.target == sensorPin) {
    // サイン波の振幅を0にセット
    sine.setAmp(0);
  }
}

// パターンを検索
int findPattern(int state[]) {
  // 指使いのテーブルと与えられたパターンを順次比較
  for (int i = 0; i < FINGERING_TABLE.length; i++) {
    // 一致するパターンが見つかったら
    if (Arrays.equals(state, FINGERING_TABLE[i])) {
      // 現在のインデックスを返す
      return i;
    }
  }

  // 最後まで見つからなかったらNOT_FOUNDを返す
  return NOT_FOUND;
}

// escキーでスケッチを停止した時に呼ばれる
void stop() {
  // Minimに関連した終了処理を行う
  out.close();
  minim.stop();

  // 元の終了処理を行う
  super.stop();
}

