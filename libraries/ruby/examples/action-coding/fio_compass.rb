# === Overview
# A simple example to show a usage of Firmata I2C
# Draw a triangle to show current heading of a compass
#
# [Author] Shigeru Kobayashi
# [License] The new BSD license
# === Operating environment
# * a HMC6352 compass module (e.g. SparkFun SEN-07915)
# * Funnel 008 or later
# * JRuby 1.1.*
# * Processing 0135 or higher
# * action-coding
# === Connection
# * A2: GND
# * A3: VCC
# * A4: SDA
# * A5: SCL
# === Reference
# * http://code.google.com/p/action-coding/
# * http://www.arduino.cc/playground/Interfacing/Firmata
# * http://www.sparkfun.com/commerce/product_info.php?products_id=7915

$: << '../..'

require 'funnel'
include Funnel

def setup
  size 400, 400

  config = Fio.FIRMATA
  @fio = Fio.new :applet => self, :config => config, :nodes => [1]
  @compass = HMC6352.new @fio.io_module(1)
end

def draw
  @compass.update
  heading = @compass.heading

  background 0
  translate 200, 200
  rotate heading / 180 * PI
  noStroke
  smooth
  fill 255
  ellipse 0, 0, 200, 200
  fill 150
  triangle 0, -100, -25, 25, 25, 25
end
