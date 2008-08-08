# === Overview
# A simple accelerometer example for Funnel I/O modules
# [Author] Shigeru Kobayashi
# [License] The new BSD license
# [Original] RGB Cube (distributed as a part of Processing 0135)
# === Operating environment
# * a Fio (Funnel I/O module) with Firmata v2 firmware
# * an accelerometer
# * Funnel 008 or later
# * JRuby 1.1.*
# * Processing 0135
# * action-coding
# === Connection
# * A0: accelerometer (Z)
# * A1: accelerometer (Y)
# * A2: accelerometer (X)
# === Reference
# * http://processing.org/learning/examples/rgbcube.html
# * http://code.google.com/p/action-coding/
# * http://www.arduino.cc/playground/Interfacing/Firmata

$: << '../..'

require 'funnel'
include Funnel

X = 2
Y = 1

def setup
  size 400, 400, P3D
  frameRate 30
  noStroke
  colorMode RGB, 1

  nodes = [1]
  @system = Fio.new :applet => self, :nodes => nodes
  @fio = @system.io_module nodes.first
  
  f1 = [
    Convolution.new(Convolution::MOVING_AVERAGE),
    Scaler.new(0.30, 0.70, -1, 1)
  ]
  
  f2 = [
    Convolution.new(Convolution::MOVING_AVERAGE),
    Scaler.new(0.30, 0.70, -1, 1)
  ]
  
  @fio.a(X).filters = f1
  @fio.a(Y).filters = f2
end

def draw
  background 0

  pushMatrix
    translate 200, 200, -30
    rotateZ -asin(@fio.a(Y).value)
    rotateX asin(@fio.a(X).value)
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
