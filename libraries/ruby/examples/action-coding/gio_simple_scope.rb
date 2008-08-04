# === Overview
# A simple example featuring Scope for Gainer I/O modules
# [Author] Shigeru Kobayashi
# [License] The new BSD license
# === Operating environment
# * a Gainer I/O module
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
