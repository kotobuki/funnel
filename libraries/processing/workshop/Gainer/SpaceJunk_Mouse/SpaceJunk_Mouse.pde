/*
SpaceJunk_Mouse
Examples -> 3D and OpenGL -> OpenGL -> Space Junk
をマウスからコントロールできるように改造したものです
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

//used for oveall rotation
float ang;

//cube count-lower/raise to test P3D/OPENGL performance
int limit = 500;

//array for all cubes
Cube[]cubes = new Cube[limit];

/*
変更(1)
カメラの水平方向、垂直方向の位置
*/
float tx = 0;
float ty = 0;

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
  変更(2)
  マウスが中心から離れるにつれ、水平方向・垂直方向に進む速度を上昇させる
  */
  float vx = mouseX/(float)width - 0.5;
  float vy = mouseY/(float)height - 0.5;
  tx -= vx;
  ty -= vy;
  
  /*center geometry in display windwow.
   you can change 3rd argument ('0')
   to move block group closer(+)/further(-)*/
  
  /*
  変更(3)
  マウスによってカメラの移動に遊びを持たせる。奥行き方向には強制的に進む
  */
  translate(width/2 + tx, height/2 + ty, -200+frameCount);
  
  /*
  変更(4)
  以下のオリジナルのコードはコメントアウト。進行方向にカメラが少し向くようにする
  //rotate around y and x axes
  rotateY(radians(ang));
  rotateX(radians(ang));
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

