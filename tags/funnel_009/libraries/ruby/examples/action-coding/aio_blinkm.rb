# === Overview
# A simple example to show a usage of Firmata I2C
# Control a BlinkM
#
# [Author] Shigeru Kobayashi
# [License] The new BSD license
# === Operating environment
# * a BlinkM
# * Funnel 009 or later
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
# * http://thingm.com/products/blinkm

$: << '../..'

require 'funnel'
include Funnel

def setup
  size 400, 400

  config = Arduino.FIRMATA
  @aio = Arduino.new :applet => self, :config => config
  @led = BlinkM.new @aio
  @led.stop_script
  @led.fade_to_hsb_color [0, 255, 255], 0
end

def draw
  background 0
end

def mousePressed
  @led.fade_to_random_hsb_color [255, 0, 0], 10
end