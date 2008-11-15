# === Overview
# A simple example to show a usage of Firmata I2C
# Get color information from an Avago ADJD-S371-Q999
#
# [Author] Shigeru Kobayashi
# [License] The new BSD license
# === Operating environment
# * an Avago ADJD-S371-Q999 color light sensor
# * Funnel 009 or later
# * JRuby 1.1.*
# * Processing 0135 or higher
# * action-coding
# === Connection
# * 3V3: 3.3V
# * GND: GND
# * A4: SDA
# * A5: SCL
# === Reference
# * http://code.google.com/p/action-coding/
# * http://www.arduino.cc/playground/Interfacing/Firmata
# * http://www.sparkfun.com/commerce/product_info.php?products_id=8663

$: << '../..'

require 'funnel'
include Funnel

def setup
  size 400, 400

  config = Fio.FIRMATA
  @fio = Fio.new :applet => self, :config => config, :nodes => [1]
  @color_sensor = ADJD_S371_QR999.new @fio.io_module(1)
end

def draw
  @color_sensor.update

  background @color_sensor.r, @color_sensor.g, @color_sensor.b
end