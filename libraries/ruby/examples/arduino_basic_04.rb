#!/usr/bin/env ruby -wKU

# === Connection
# * A0: a rotary potentiometer
# * D9: a LED with a current limiting resistor (or the on-board LED)

$: << '..'

require 'funnel'
include Funnel

config = Arduino.FIRMATA
config.set_digital_pin_mode(9, PWM)
aio = Arduino.new :config => config

# a() and d() are shortcuts for analog_pin() and digital_pin()
sensorPin = aio.a(0)
ledPin = aio.d(13)

sensorPin.on CHANGE do
  puts "A0: #{sensorPin.value}"
  ledPin.value = sensorPin.value
end

sleep(10)
