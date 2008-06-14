#!/usr/bin/env ruby -wKU
$: << '..'

require 'funnel'
include Funnel

gio = Gainer.new

gio.ain(0).filters = [SetPoint.new(0.2, 0.05)]
gio.ain(0).on CHANGE do |event|
  puts "ain 0: #{event.target.last_value} > #{event.target.value}"
end

gio.button.on RISING_EDGE do
  puts "button: pressed"
end

gio.button.on FALLING_EDGE do
  puts "button: released"
end

Osc.service_interval = 33
blinker = Osc.new(Osc::SQUARE, 2.0, 0)
gio.led.filters = [blinker]
blinker.reset
blinker.start

sleep(5)
