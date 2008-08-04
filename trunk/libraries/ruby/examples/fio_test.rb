#!/usr/bin/env ruby
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
