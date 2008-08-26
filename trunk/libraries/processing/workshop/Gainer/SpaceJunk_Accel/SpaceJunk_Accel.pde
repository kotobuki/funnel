/*
SpaceJunk_Accel
SpaceJunk_Mouseを加速度センサから
コントロールできるように改造したものです
*/

/**
 * Space Junk  
 * By Ira Greenberg 
 * zoom suggestion 
 * By Danny Greenberg
 * 
 * Rotating cubes in space using
 * a custom Cube class. Color controlled 
 * by light sources.
 */

/*need to import opengl library to use OPENGL 
 rendering mode for hardware acceleration*/
import processing.opengl.*;

/*
変更(1)
Funnelライブラリをインポートする
*/
import processing.funnel.*;

//used for oveall rotation
float ang;

//cube count-lower/raise to test P3D/OPENGL performance
int limit = 500;

//array for all cubes
Cube[]cubes = new Cube[limit];

/*
カメラの水平方向、垂直方向の位置
*/
float tx = 0;
float ty = 0;

Gainer gainer;

void setup(){
  //try substituting P3D for OPENGL 
  //argument to test performance
  size(640, 480, OPENGL); 
  background(0); 

  //instantiate cubes, passing in random vals for size and postion
  for (int i = 0; i< cubes.length; i++){
    cubes[i] = new Cube(int(random(-10, 10)), int(random(-10, 10)), 
    int(random(-20, 20)), int(random(-140, 140)), int(random(-140, 140)), 
    int(random(-140, 140)));
  }
  
  /*
  変更(2)
  Funnelを準備し、センサからの入力値を適切な範囲に調整しつつ、
  動きを滑らかにするためにスムージングをかける
  */
  gainer = new Gainer(this, Gainer.MODE1);
  
  Filter f0[] = {
    new Scaler(0.25, 0.75, -1, 1, Scaler.LINEAR, true),
    new Convolution(Convolution.MOVING_AVERAGE)   
  };
  gainer.analogInput(0).filters = f0;
  
  Filter f1[] = {
    new Scaler(0.25, 0.75, -1, 1, Scaler.LINEAR, true),
    new Convolution(Convolution.MOVING_AVERAGE)   
  };
  gainer.analogInput(1).filters = f1;
}

void draw(){
  background(0); 
  fill(200);

  //set up some different colored lights
  pointLight(51, 102, 255, 65, 60, 100); 
  pointLight(200, 40, 60, -65, -60, -150);

  //raise overall light in scene 
  ambientLight(70, 70, 10); 
  
  /*
  変更(3)
  加速度センサのロール角とピッチ角を、水平方向・垂直方向に進む速度に対応させる
  */
  float vx = asin(gainer.analogInput(1).value);
  float vy = -asin(gainer.analogInput(0).value);
  tx -= vx;
  ty -= vy;
  
  /*center geometry in display windwow.
   you can change 3rd argument ('0')
   to move block group closer(+)/further(-)*/
  
  /*
  カメラの移動に遊びを持たせる。奥行き方向には強制的に進む
  */
  translate(width/2 + tx, height/2 + ty, -200+frameCount);
  
  /*
  進行方向にカメラが少し向くようにする
  */
  rotateY(vx * 0.5);
  rotateX(-vy * 0.5);

  //draw cubes
  for (int i = 0; i< cubes.length; i++){
    cubes[i].drawCube();
  }
  //used in rotate function calls above
  ang++;
}

//simple Cube class, based on Quads
class Cube {

  //properties
  int w, h, d;
  int shiftX, shiftY, shiftZ;

  //constructor
  Cube(int w, int h, int d, int shiftX, int shiftY, int shiftZ){
    this.w = w;
    this.h = h;
    this.d = d;
    this.shiftX = shiftX;
    this.shiftY = shiftY;
    this.shiftZ = shiftZ;
  }

  /*main cube drawing method, which looks 
   more confusing than it really is. It's 
   just a bunch of rectangles drawn for 
   each cube face*/
  void drawCube(){
    beginShape(QUADS);
    //front face
    vertex(-w/2 + shiftX, -h/2 + shiftY, -d/2 + shiftZ); 
    vertex(w + shiftX, -h/2 + shiftY, -d/2 + shiftZ); 
    vertex(w + shiftX, h + shiftY, -d/2 + shiftZ); 
    vertex(-w/2 + shiftX, h + shiftY, -d/2 + shiftZ); 

    //back face
    vertex(-w/2 + shiftX, -h/2 + shiftY, d + shiftZ); 
    vertex(w + shiftX, -h/2 + shiftY, d + shiftZ); 
    vertex(w + shiftX, h + shiftY, d + shiftZ); 
    vertex(-w/2 + shiftX, h + shiftY, d + shiftZ);

    //left face
    vertex(-w/2 + shiftX, -h/2 + shiftY, -d/2 + shiftZ); 
    vertex(-w/2 + shiftX, -h/2 + shiftY, d + shiftZ); 
    vertex(-w/2 + shiftX, h + shiftY, d + shiftZ); 
    vertex(-w/2 + shiftX, h + shiftY, -d/2 + shiftZ); 

    //right face
    vertex(w + shiftX, -h/2 + shiftY, -d/2 + shiftZ); 
    vertex(w + shiftX, -h/2 + shiftY, d + shiftZ); 
    vertex(w + shiftX, h + shiftY, d + shiftZ); 
    vertex(w + shiftX, h + shiftY, -d/2 + shiftZ); 

    //top face
    vertex(-w/2 + shiftX, -h/2 + shiftY, -d/2 + shiftZ); 
    vertex(w + shiftX, -h/2 + shiftY, -d/2 + shiftZ); 
    vertex(w + shiftX, -h/2 + shiftY, d + shiftZ); 
    vertex(-w/2 + shiftX, -h/2 + shiftY, d + shiftZ); 

    //bottom face
    vertex(-w/2 + shiftX, h + shiftY, -d/2 + shiftZ); 
    vertex(w + shiftX, h + shiftY, -d/2 + shiftZ); 
    vertex(w + shiftX, h + shiftY, d + shiftZ); 
    vertex(-w/2 + shiftX, h + shiftY, d + shiftZ); 

    endShape(); 

    //add some rotation to each box for pizazz.
    rotateY(radians(1));
    rotateX(radians(1));
    rotateZ(radians(1));
  }
}

