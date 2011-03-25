#!/usr/bin/env ruby -wKU

# === Connection
# * D2: a tactile switch with a pull-down resistor
# * D13: a LED with a current limiting resistor (or the on-board LED)

$: << '..'

# prepare for using the Funnel library
require 'funnel'
include Funnel

# configure pin(s) of the Arduino board
config = Arduino.FIRMATA
config.set_digital_pin_mode(2, IN)
config.set_digital_pin_mode(13, OUT)
aio = Arduino.new :config => config

# name the D2 and D13 pin as buttonPin ledPin to make the code more human readable
buttonPin = aio.digital_pin(2)
ledPin = aio.digital_pin(13)

# if the button is pressed, turn on the LED
buttonPin.on RISING_EDGE do
  puts "pressed"
  ledPin.value = 1
end

# if the button is pressed, turn off the LED
buttonPin.on FALLING_EDGE do
  puts "released"
  ledPin.value = 0
end

# run the code for 10 seconds
sleep(10)
