#!/usr/bin/env ruby -wKU

# === Overview
# A simple example for Arduino I/O boards
# [Author] Shigeru Kobayashi
# [License] The new BSD license
# === Operating environment
# * an Arduino I/O board with Firmata v2 firmware
# * a sensor (e.g. photocell, potentiometer)
# * a LED with a resistor (e.g. 330ohm)
# * a switch with a pull-down or pull-up resistor
# * Funnel 009 or later
# * Ruby 1.8.6
# === Connection
# * A0: a sensor
# * D11: a LED
# * D12: a switch
# * D13: a on-board LED
# === Reference
# * http://www.arduino.cc/playground/Interfacing/Firmata

$: << '..'

require 'funnel'
include Funnel

config = Arduino.FIRMATA
config.set_digital_pin_mode(11, PWM)
config.set_digital_pin_mode(12, IN)
config.set_digital_pin_mode(13, OUT)
aio = Arduino.new :config => config

aio.a(0).on CHANGE do |event|
  puts "A0: #{event.target.last_value} > #{event.target.value}"
end

aio.d(12).on CHANGE do |event|
  puts "D12: #{event.target.last_value} > #{event.target.value}"
end

Osc.service_interval = 20
blinker = Osc.new Osc::SQUARE, 2.0, 0
aio.d(13).filters = [blinker]
blinker.reset
blinker.start

fader = Osc.new(Osc::SIN, 1.0, 0)
scaler = Scaler.new 0.0, 1.0, 0.0, 1.0, Scaler::SQUARE
aio.d(11).filters = [fader, scaler]
fader.reset
fader.start

sleep(10)