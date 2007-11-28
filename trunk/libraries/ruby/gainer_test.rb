#!/usr/bin/env ruby -wKU

require 'funnel/gainer'

module Funnel
  gio = Gainer.new(Gainer::MODE1)

  gio.ain(0).filters = [SetPoint.new(0.2, 0.05)]
  gio.ain(0).on PortEvent::CHANGE do |event|
    puts "ain 0: #{event.target.last_value} > #{event.target.value}"
  end

  gio.button.on PortEvent::RISING_EDGE do
    puts "button: pressed"
  end

  gio.button.on PortEvent::FALLING_EDGE do
    puts "button: released"
  end

  Osc.service_interval = 33
  blinker = Osc.new(Osc::SQUARE, 2.0, 0)
  gio.led.filters = [blinker]
  blinker.reset
  blinker.start

  sleep(5)
end
