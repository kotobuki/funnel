# === Overview
# A simple example featuring Osc for Gainer I/O modules
# [Author] Shigeru Kobayashi
# [License] The new BSD license
# === Operating environment
# * a Gainer I/O module
# * a LED with a resistor (r.g. 330ohm)
# * Funnel 008 or later
# * JRuby 1.1.*
# * Processing 0135
# * action-coding
# === Connection
# * aout 0: a LED
# === Reference
# * http://code.google.com/p/action-coding/

$: << '../..'

require 'funnel'
include Funnel

def setup
  size 320, 160

  textFont createFont "CourierNewPSMT", 12

  @gio = Gainer.new :applet => self

  # try the other wave functions (e.g. Osc::SIN, Osc::SAW) or frequencies
  @osc = Osc.new Osc::SQUARE, 1, 0
  @gio.aout(0).filters = [@osc]

  @scope = Scope.new "value", 30, 35
end

def draw
  background 100
  @scope.draw self, @osc.value
end

def mousePressed
  @osc.reset
  @osc.start
end
