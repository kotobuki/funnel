$: << '../..'

require 'funnel'
include Funnel

R = 11
G = 18
B = 19

def setup
  size 360, 480
  frameRate 30

  font = createFont "CourierNewPSMT", 12
  textFont font

  nodes = [15]
  @fio = Fio.new :applet => self, :nodes => nodes
  @scope = Scope.new "Brightness", 30, 35
end

def draw
  background 0

  brightness = 1 - @fio.io_module(15).port(0).value
  @scope.draw self, brightness
  @fio.io_module(ALL).port(R).value = brightness
  @fio.io_module(ALL).port(G).value = brightness
  @fio.io_module(ALL).port(B).value = brightness
end
