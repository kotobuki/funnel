$: << '../..'

require 'funnel'
include Funnel

def setup
  size 320, 160

  textFont(createFont "CourierNewPSMT", 12)

  @gio = Gainer.new :applet => self

  Osc.service_interval = 33
  # @blinker = Osc.new(Osc::SIN, 1.0, 1.0, 0, -0.25, 1)
  @blinker = Osc.new(Osc::TRIANGLE, 1, 2)
  @gio.aout(0).filters = [@blinker]

  @scope = Scope.new "value", 30, 35
end

def draw
  background 100
  @scope.draw self, @blinker.value
end

def mousePressed
  @blinker.reset
  @blinker.start
end
