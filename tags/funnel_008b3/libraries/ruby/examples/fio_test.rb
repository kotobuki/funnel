#!/usr/bin/env ruby

# === Overview
# A simple full color LED example featuring Osc for Funnel I/O modules
# Drive a full color LED with multiple 
# [Author] Shigeru Kobayashi
# [License] The new BSD license
# === Operating environment
# * Fio (Funnel I/O module) x 1 with Firmata v2 firmware
# * a full color LED
# * Funnel 008 or later
# * Ruby 1.8.6
# === Connection
# * D3: a full Color LED (R)
# * D10: a full Color LED (G)
# * D11: a full Color LED (B)
# === Reference
# * http://code.google.com/p/action-coding/
# * http://www.arduino.cc/playground/Interfacing/Firmata

$: << '..'

require 'funnel'
include Funnel

R = 3
G = 10
B = 11

config = Fio.FIRMATA
config.set_digital_pin_mode(R, PWM)
config.set_digital_pin_mode(G, PWM)
config.set_digital_pin_mode(B, PWM)

nodes = [1]
@fio = Fio.new :config => config, :nodes => nodes

@fio.io_module(1).a(0).on CHANGE do |event|
  puts "A0: #{event.target.value}"
end

@osc_r = Osc.new Osc::SIN, 0.5, 1, 0, 0, 0
@osc_g = Osc.new Osc::SIN, 0.5, 1, 0, 0.33, 0
@osc_b = Osc.new Osc::SIN, 0.5, 1, 0, 0.66, 0

@fio.io_module(ALL).d(R).filters = [@osc_r]
@fio.io_module(ALL).d(G).filters = [@osc_g]
@fio.io_module(ALL).d(B).filters = [@osc_b]
@osc_r.start
@osc_g.start
@osc_b.start

sleep 10
