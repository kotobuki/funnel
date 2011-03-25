import processing.funnel.*;
import processing.funnel.i2c.*;

Arduino arduino;

// デジタルコンパスHMC6352
HMC6352 compass;

void setup() {
  size(400, 400);

  // A2とA3を電源ピンにセットしてArduinoを初期化
  Configuration config = Arduino.FIRMATA;
  config.enablePowerPins();
  arduino = new Arduino(this, config);

  // デジタルコンパスを表す変数を初期化
  compass = new HMC6352(arduino.iomodule());

  // 以降の描画をすべてスムーズにする
  smooth();
}

void draw() {
  // コンパスの状態を更新
  compass.update();

  // 背景を白で塗りつぶす
  background(255);

  // 描画の中心をウィンドウの中央に移動
  translate(width / 2, height / 2);

  // 現在の描画マトリクスを保存した後
  // コンパスの方位にあわせて回転
  pushMatrix();
  rotate(radians(compass.heading));

  // コンパスの針を描画するためのパラメータをセット
  stroke(0);
  fill(0);
  strokeWeight(1);

  // コンパスの針を描画
  beginShape();
  vertex(0, -100);
  vertex(20, 20);
  vertex(0, 0);
  vertex(-20, 20);
  vertex(0, -100);
  endShape(CLOSE);

  // 描画マトリクスを元に戻す
  popMatrix();

  // コンパスの周囲の円を描画
  noFill();
  strokeWeight(2);
  ellipse(0, 0, 200, 200);
}
