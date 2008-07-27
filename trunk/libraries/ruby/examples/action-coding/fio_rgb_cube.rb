$: << '../..'

require 'funnel'
include Funnel

def setup
  size 400, 400, P3D
  frameRate 30
  noStroke
  colorMode RGB, 1

  nodes = [13]
  @system = Fio.new :applet => self, :nodes => nodes
  @fio = @system.io_module 13
  
  f1 = [
    Convolution(Convolutin::MOVING_AVERAGE),
    Scaler(0.30, 0.70, -1, 1, Scaler::LINEAR, true)
  ]
  
  f2 = [
    Convolution(Convolutin::MOVING_AVERAGE),
    Scaler(0.30, 0.70, -1, 1, Scaler::LINEAR, true)
  ]
  
  @fio.port(1).value = f1
  @fio.port(2).value = f2
end

def draw
  background 0

  pushMatrix
    translate 200, 200, -30
    rotateZ -asin(fio.port(1).value);
    rotateX asin(fio.port(2).value);
    scale 100

    beginShape QUADS
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
    endShape
  popMatrix
end
