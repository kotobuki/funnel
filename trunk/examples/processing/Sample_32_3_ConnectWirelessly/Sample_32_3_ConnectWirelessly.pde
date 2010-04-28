import processing.funnel.*;

// Arduino Fio
Fio fio;

// センサに接続したピン
Pin sensorPin;

void setup() {
  size(400, 200);

  // Fioのコンストラクタに利用するIDを配列で渡す
  int[] moduleIDs = { 1 };
  fio = new Fio(this, moduleIDs, Fio.FIRMATA);

  // センサに接続したピンを表す変数を初期化
  sensorPin = fio.iomodule(1).analogPin(0);

  // 背景を黒で塗りつぶす
  background(0);
}

void draw() {
  // 今回描画するx 座標をフレーム数のカウンタから求める
  int x = frameCount % width;

  // 今回描画するx 座標を黒で塗りつぶす
  stroke(0);
  line(x, 0, x, height - 1);

  // センサの値をウィンドウの縦幅にスケーリングして点を描画する
  stroke(255);
  point(x, map(sensorPin.value, 0, 1, height - 1, 0));
}

