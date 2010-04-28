import processing.funnel.*;

// バッファの長さ
final int BUFFER_LENGTH = 5;

// バッファの中央のインデックス
final int INDEX_OF_MIDDLE = BUFFER_LENGTH / 2;

// Arduino
Arduino arduino;

// センサに接続したピン
Pin sensorPin;

// センサから読み取った値を保持するためのバッファ
float[] buffer = new float[BUFFER_LENGTH];

// ソート用のバッファ
float[] sortBuffer = new float[BUFFER_LENGTH];

// バッファにデータを書き込むインデックス
int index = 0;

// 表示位置のカウンタ
int count = 0;

void setup() {
  size(400, 300);

  // Arduinoのインスタンスを生成してセンサに接続したピンを表す変数を初期化
  arduino = new Arduino(this, Arduino.FIRMATA);
  sensorPin = arduino.analogPin(0);

  // 背景を黒で塗りつぶす
  background(0);
}

void draw() {
  // これから描画する部分を黒で塗りつぶす
  stroke(0);
  line(count, 0, count, height - 1);

  // 3 つのグラフのx軸を描画する
  stroke(100);
  line(0, 99, width - 1, 99);
  line(0, 199, width - 1, 199);
  line(0, 299, width - 1, 299);

  // センサの値を読み取った値をバッファに書き込む
  buffer[index] = sensorPin.value;

  // MeanフィルタとMedianフィルタをそれぞれ実行
  float smoothedByMean = smoothByMeanFilter();
  float smoothedByMedian = smoothByMedianFilter();

  // 元の値、Meanフィルタをかけた値、Medianフィルタをかけた値を表示
  stroke(255);
  point(count, map(buffer[index], 0, 1, 99, 0));
  point(count, map(smoothedByMean, 0, 1, 199, 100));
  point(count, map(smoothedByMedian, 0, 1, 299, 200));

  // バッファの書き込み位置を示すカウンタをインクリメント
  index = (index + 1) % buffer.length;

  // 表示用のカウンタをインクリメント（画面の端まで来たら折り返す）
  count = (count + 1) % width;
}

// Meanフィルタ
float smoothByMeanFilter() {
  // バッファの値の合計を集計するための変数
  float sum = 0;

  // バッファの値の合計を集計
  for (int i = 0; i < buffer.length; i++) {
    sum += buffer[i];
  }

  // 平均をフィルタの出力結果として返す
  return (sum / buffer.length);
}

// Medianフィルタ
float smoothByMedianFilter() {
  // ソートに使用するバッファにデータをコピー
  for (int i = 0; i < sortBuffer.length; i++) {
    sortBuffer[i] = buffer[i];
  }

  // ソート
  sort(sortBuffer);

  // ソート結果の中央の値を出力結果として返す
  return sortBuffer[INDEX_OF_MIDDLE];
}

