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
 */

Gainer gainer;

void setup() 
{ 
  size(400, 400, P3D);
  frameRate(10);
  noStroke(); 
  colorMode(RGB, 1); 

  gainer = new Gainer(this, Gainer.MODE1);
  
  Filter f0[] = {
    new Convolution(Convolution.MOVING_AVERAGE),
    new Scaler(0.31, 0.71, -1.0, 1.0, Scaler.LINEAR, true)
  };
  Filter f1[] = {
    new Convolution(Convolution.MOVING_AVERAGE),
    new Scaler(0.30, 0.70, -1.0, 1.0, Scaler.LINEAR, true)
  };
  gainer.analogInput(0).setFilters(f0); 
  gainer.analogInput(1).setFilters(f1); 
} 
 
void draw() 
{ 
  background(0.5, 0.5, 0.45);
  
  pushMatrix();
 
  translate(width/2, height/2, -30); 

//  println("ain 0: " + gainer.analogInput(0).value + "," + asin(gainer.analogInput(0).value));
//  println("ain 1: " + gainer.analogInput(1).value + "," + asin(gainer.analogInput(1).value));

  rotateZ(asin(gainer.analogInput(1).value));
  rotateX(-asin(gainer.analogInput(0).value));
  
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
