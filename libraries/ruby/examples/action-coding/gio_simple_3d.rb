$: << '../..'

require 'funnel'
include Funnel

def setup
  size 400, 400, OPENGL
  @gio = Gainer.new :applet => self
  @val = 0
end

def draw
  background 0

  lights
  noStroke
  translate 200, 200
  rotateX @val
  rotateY @val
  rotateZ @val
  box 100
  @val = @val + @gio.ain(0).value * 0.1
end
