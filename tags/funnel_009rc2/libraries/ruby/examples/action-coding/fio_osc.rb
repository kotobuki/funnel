# === Overview
# A simple full color LED example featuring Osc for Funnel I/O modules
# Drive a full color LED with multiple 
# [Author] Shigeru Kobayashi
# [License] The new BSD license
# === Operating environment
# * a Fio (Funnel I/O module) with Firmata v2 firmware
# * a full color LED
# * Funnel 008 or later
# * JRuby 1.1.*
# * Processing 0135
# * action-coding
# === Connection
# * D3: a full Color LED (R)
# * D10: a full Color LED (G)
# * D11: a full Color LED (B)
# === Reference
# * http://code.google.com/p/action-coding/
# * http://www.arduino.cc/playground/Interfacing/Firmata

$: << '../..'

require 'funnel'
include Funnel

R = 3
G = 10
B = 11

def setup
  size 360, 480

  config = Fio.FIRMATA
  config.set_digital_pin_mode(R, PWM)
  config.set_digital_pin_mode(G, PWM)
  config.set_digital_pin_mode(B, PWM)

  nodes = [1]
  @fio = Fio.new :applet => self, :config => config, :nodes => nodes
  @osc_r = Osc.new Osc::SIN, 0.5, 1, 0, 0, 5
  @osc_g = Osc.new Osc::SIN, 0.5, 1, 0, 0.33, 5
  @osc_b = Osc.new Osc::SIN, 0.5, 1, 0, 0.66, 5

  @fio.io_module(ALL).pin(R).filters = [@osc_r, Scaler.new(0, 1, 1, 0)]
  @fio.io_module(ALL).pin(G).filters = [@osc_g, Scaler.new(0, 1, 1, 0)]
  @fio.io_module(ALL).pin(B).filters = [@osc_b, Scaler.new(0, 1, 1, 0)]
  @osc_r.start
  @osc_g.start
  @osc_b.start
end

def draw
  background 0
end
