#!/usr/bin/env ruby -wKU

$: << '..'

# prepare for using the Funnel library
require 'funnel'
include Funnel

# configure pin(s) of the Arduino board
config = Arduino.FIRMATA
config.set_digital_pin_mode(13, OUT)
aio = Arduino.new :config => config

# repeat "ON, sleep 0.5s, OFF, sleep 0.5" 10 times
10.times do
  aio.digital_pin(13).value = 1
  sleep(0.5)
  aio.digital_pin(13).value = 0
  sleep(0.5)
end
