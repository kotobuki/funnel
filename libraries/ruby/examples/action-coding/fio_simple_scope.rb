# === Overview
# A simple example featuring Scope for Funnel I/O modules
# [Author] Shigeru Kobayashi
# [License] The new BSD license
# === Operating environment
# * Fio (Funnel I/O module) x 1 with Firmata v2 firmware
# * an accelerometer
# * Funnel 008 or later
# * JRuby 1.1.*
# * Processing 0135
# * action-coding
# === Connection
# * A0: accelerometer (Z)
# * A1: accelerometer (Y)
# * A2: accelerometer (X)
# * D12: switch
# === Reference
# * http://code.google.com/p/action-coding/
# * http://www.arduino.cc/playground/Interfacing/Firmata

$: << '../..'

require 'funnel'
include Funnel

def setup
  size 360, 680
  frameRate 30

  font = createFont "CourierNewPSMT", 12
  textFont font

  config = Fio.FIRMATA
  config.set_digital_pin_mode 12, IN
  nodes = [1]
  @system = Fio.new :applet => self, :config => config, :nodes => nodes
  @fio = @system.io_module nodes.first

  @scopeX = Scope.new "X", 30, 35
  @scopeY = Scope.new "Y", 30, 165
  @scopeZ = Scope.new "Z", 30, 295
  @scopeD = Scope.new "SW", 30, 425
end

def draw
  background 0

  @scopeX.draw self, @fio.a(2).value
  @scopeY.draw self, @fio.a(1).value
  @scopeZ.draw self, @fio.a(0).value
  @scopeD.draw self, @fio.d(12).value
end
