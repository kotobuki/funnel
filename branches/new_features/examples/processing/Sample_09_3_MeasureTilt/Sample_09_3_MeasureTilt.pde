import processing.funnel.*;

Arduino arduino;

// 加速度センサのx 軸とy 軸に接続したアナログピン
Pin xAxisPin;
Pin yAxisPin;

void setup() {
  size(400, 400, P3D);
  frameRate(30);
  noStroke();
  colorMode(RGB, 1);

  // Arduinoのインスタンスを生成
  arduino = new Arduino(this, Arduino.FIRMATA);

  // x 軸とy 軸に接続したピンを初期化
  xAxisPin = arduino.analogPin(0);
  yAxisPin = arduino.analogPin(1);

  // x 軸とy 軸に細かな変動を取り除くためのConvolutionフィルタと
  // スケーリングするためのScalerフィルタをセットする
  xAxisPin.addFilter(new Convolution(
                     Convolution.MOVING_AVERAGE));
  xAxisPin.addFilter(new Scaler(0.3, 0.7, -1.0, 1.0));
  yAxisPin.addFilter(new Convolution(
                     Convolution.MOVING_AVERAGE));
  yAxisPin.addFilter(new Scaler(0.3, 0.7, -1.0, 1.0));
}

void draw() {
  background(0.5, 0.5, 0.45);

  pushMatrix();

  translate(width/2, height/2, -30);

  // マウスの代わりに加速度センサの値でコントロール
  rotateZ(asin(yAxisPin.value));
  rotateX(-asin(xAxisPin.value));

  scale(100);

  beginShape(QUADS);

  fill(0, 1, 1); 
  vertex(-1,  1,  1);
  fill(1, 1, 1); 
  vertex( 1,  1,  1);
  fill(1, 0, 1); 
  vertex( 1, -1,  1);
  fill(0, 0, 1); 
  vertex(-1, -1,  1);

  fill(1, 1, 1); 
  vertex( 1,  1,  1);
  fill(1, 1, 0); 
  vertex( 1,  1, -1);
  fill(1, 0, 0); 
  vertex( 1, -1, -1);
  fill(1, 0, 1); 
  vertex( 1, -1,  1);

  fill(1, 1, 0); 
  vertex( 1,  1, -1);
  fill(0, 1, 0); 
  vertex(-1,  1, -1);
  fill(0, 0, 0); 
  vertex(-1, -1, -1);
  fill(1, 0, 0); 
  vertex( 1, -1, -1);

  fill(0, 1, 0); 
  vertex(-1,  1, -1);
  fill(0, 1, 1); 
  vertex(-1,  1,  1);
  fill(0, 0, 1); 
  vertex(-1, -1,  1);
  fill(0, 0, 0); 
  vertex(-1, -1, -1);

  fill(0, 1, 0); 
  vertex(-1,  1, -1);
  fill(1, 1, 0); 
  vertex( 1,  1, -1);
  fill(1, 1, 1); 
  vertex( 1,  1,  1);
  fill(0, 1, 1); 
  vertex(-1,  1,  1);

  fill(0, 0, 0); 
  vertex(-1, -1, -1);
  fill(1, 0, 0); 
  vertex( 1, -1, -1);
  fill(1, 0, 1); 
  vertex( 1, -1,  1);
  fill(0, 0, 1); 
  vertex(-1, -1,  1);

  endShape();
  popMatrix();
}

