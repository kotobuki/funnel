#!/usr/bin/env ruby -wKU

$: << '..'

# prepare for using the Funnel library
require 'funnel'
include Funnel

# configure pin(s) of the Arduino board
config = Arduino.FIRMATA
config.set_digital_pin_mode(13, OUT)
aio = Arduino.new :config => config

# name the D13 pin connected to the LED as ledPin to make the code more human readable
ledPin = aio.digital_pin(13)

# repeat "ON, sleep 0.5s, OFF, sleep 0.5" 10 times
10.times do
  ledPin.value = 1
  sleep(0.5)
  ledPin.value = 0
  sleep(0.5)
end
