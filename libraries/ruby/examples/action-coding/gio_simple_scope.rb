$: << '../..'

require 'funnel'
include Funnel

def setup
  size 340, 480
  frameRate 30

  font = createFont "CourierNewPSMT", 12
  textFont font

  @gio = Gainer.new :applet => self
  @scope = Scope.new "button", 30, 35
end

def draw
  background(0)
  @scope.draw self, @gio.button.value
end
