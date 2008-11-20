# === Overview
# A simple OpenGL example for Gainer I/O modules
# [Author] Shigeru Kobayashi
# [License] The new BSD license
# === Operating environment
# * a Gainer I/O module
# * a sensor (e.g. photocell, potentiometer)
# * Funnel 008 or later
# * JRuby 1.1.*
# * Processing 0135
# * action-coding
# === Connection
# * ain 0: sensor
# === Reference
# * http://code.google.com/p/action-coding/

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
