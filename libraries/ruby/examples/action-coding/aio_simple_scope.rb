$: << '../..'

require 'funnel'
include Funnel

def setup
  size 360, 480
  frameRate 30

  font = createFont "CourierNewPSMT", 12
  textFont font

  config = Arduino.FIRMATA
  @aio = Arduino.new :config => config, :applet => self

  @scope0 = Scope.new "X", 30, 35
  @scope1 = Scope.new "Y", 30, 165
  @scope2 = Scope.new "Z", 30, 295
end

def draw
  background 0
  @scope0.draw self, @aio.a(2).value
  @scope1.draw self, @aio.a(1).value
  @scope2.draw self, @aio.a(0).value
end
