import processing.funnel.*;

// バッファの長さ
final int BUFFER_LENGTH = 8;

// センサが振られたと判断するための閾値
final float THRESHOLD = 0.1;

Arduino arduino;

// 加速度センサのx 軸に接続したアナログピン
Pin sensorPin;

// LEDに接続したピン
Pin ledPin;

// バッファ
float[] buffer = new float[BUFFER_LENGTH];

// バッファにデータを書き込むインデックス
int index = 0;

// LEDをコントロールするためのオシレータ
Osc osc;

// グラフを表示するためのカウンタ
int count = 0;

void setup() {
  size(400, 200);

  // LEDに接続したピンのモードをPWMにセット
  Configuration config = Arduino.FIRMATA;
  config.setDigitalPinMode(9, Arduino.PWM);
  arduino = new Arduino(this, config);

  // センサとLEDに接続したピンを初期化
  sensorPin = arduino.analogPin(0);
  ledPin = arduino.digitalPin(9);

  // オシレータを初期化してイベントリスナをセット
  // 引数はApplet、波形、周波数、繰り返し回数
  osc = new Osc(this, Osc.SAW, 5, 1);
  osc.addEventListener(Osc.UPDATE, "oscUpdated");

  // 背景を黒で塗りつぶす
  background(0);
}

void draw() {
  // 今回プロットするエリアを黒で塗りつぶす
  stroke(0);
  line(count, 0, count, height - 1);

  // グラフのx 軸を描画
  stroke(100);
  line(0, 99, width - 1, 99);
  line(0, 199, width - 1, 199);

  // センサの値を読み取る
  float raw = sensorPin.value;

  // Meanフィルタでスムージングする
  float smoothed = processSample(raw);

  // 元の値との差を求める
  float diff = abs(raw - smoothed);

  // 元の値を上のグラフにプロット
  stroke(100);
  point(count, map(raw, 0, 1, 99, 0));

  // スムージングした値を上のグラフにプロット
  stroke(255);
  point(count, map(smoothed, 0, 1, 99, 0));

  // 差を下のグラフにプロット
  stroke(255);
  point(count, map(diff, 0, 1, 199, 100));

  // もし差が閾値よりも大きければLEDをブリンク
  if (diff > THRESHOLD) {
    osc.reset();
    osc.start();
  }

  // グラフ表示用のカウンタを更新
  count = (count + 1) % width;
}

// Meanフィルタ
float processSample(float raw) {
  // バッファに新しいサンプルを書き込んでインデックスを更新
  buffer[index] = raw;
  index = (index + 1) % buffer.length;

  // バッファの値の合計を集計するための変数
  float sum = 0;

  // バッファの値の合計を集計
  for (int i = 0; i < buffer.length; i++) {
    sum += buffer[i];
  }

  // 平均をフィルタの出力結果として返す
  return (sum / buffer.length);
}

// オシレータが更新されたらLED の輝度を更新
void oscUpdated(Osc osc) {
  ledPin.value = osc.value;
}
