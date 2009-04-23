import processing.funnel.*;

/**
 * RGB Cube.
 * 
 * The three primary colors of the additive color model are red, green, and blue.
 * This RGB color cube displays smooth transitions between these colors. 
 */

/**
 * NOTE:
 * Modified from the original to control Z and X axis by a mouse.
 * Replace the mouseX and mouseY by a physical controller.
 * 
 * ProcessingについてくるサンプルRGBCubeをマウスでコントロールできるように
 * したものをさらに変更してFioに接続した加速度センサでコントロールできる
 * ようにしたサンプル。
 */

Fio fio;

void setup() 
{ 
  size(400, 400, P3D);
  frameRate(10);
  noStroke(); 
  colorMode(RGB, 1); 

  int moduleIDs[] = {1};
  fio = new Fio(this, moduleIDs, Fio.FIRMATA);

  // 加速度センサの値に対して以下の2つのフィルタをセット
  // 1) スムージング（移動平均）
  // 2) スケーリング
  // Scalerに与える値はSimpleScopeFIOでの表示を参考に設定すること
  Filter f0[] = {
    new Convolution(Convolution.MOVING_AVERAGE),
    new Scaler(0.30, 0.70, -1.0, 1.0, Scaler.LINEAR, true)
  };

  Filter f1[] = {
    new Convolution(Convolution.MOVING_AVERAGE),
    new Scaler(0.30, 0.70, -1.0, 1.0, Scaler.LINEAR, true)
  };

  fio.iomodule(1).analogPin(1).filters = f0;
  fio.iomodule(1).analogPin(2).filters = f1;
} 
 
void draw() 
{ 
  background(0.5, 0.5, 0.45);
  
  pushMatrix();
 
  translate(width/2, height/2, -30); 

  rotateZ(-asin(fio.iomodule(1).analogPin(1).value));
  rotateX(asin(fio.iomodule(1).analogPin(2).value));
  
  scale(100);
  beginShape(QUADS);

  fill(0, 1, 1); vertex(-1,  1,  1);
  fill(1, 1, 1); vertex( 1,  1,  1);
  fill(1, 0, 1); vertex( 1, -1,  1);
  fill(0, 0, 1); vertex(-1, -1,  1);

  fill(1, 1, 1); vertex( 1,  1,  1);
  fill(1, 1, 0); vertex( 1,  1, -1);
  fill(1, 0, 0); vertex( 1, -1, -1);
  fill(1, 0, 1); vertex( 1, -1,  1);

  fill(1, 1, 0); vertex( 1,  1, -1);
  fill(0, 1, 0); vertex(-1,  1, -1);
  fill(0, 0, 0); vertex(-1, -1, -1);
  fill(1, 0, 0); vertex( 1, -1, -1);

  fill(0, 1, 0); vertex(-1,  1, -1);
  fill(0, 1, 1); vertex(-1,  1,  1);
  fill(0, 0, 1); vertex(-1, -1,  1);
  fill(0, 0, 0); vertex(-1, -1, -1);

  fill(0, 1, 0); vertex(-1,  1, -1);
  fill(1, 1, 0); vertex( 1,  1, -1);
  fill(1, 1, 1); vertex( 1,  1,  1);
  fill(0, 1, 1); vertex(-1,  1,  1);

  fill(0, 0, 0); vertex(-1, -1, -1);
  fill(1, 0, 0); vertex( 1, -1, -1);
  fill(1, 0, 1); vertex( 1, -1,  1);
  fill(0, 0, 1); vertex(-1, -1,  1);

  endShape();
  
  popMatrix(); 
} 

