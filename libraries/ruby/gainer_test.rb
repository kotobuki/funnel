#!/usr/bin/env ruby

require 'funnel'

module Funnel
  gio = Funnel.new('localhost', 9000, Gainer::MODE1, 33)

  gio.analog_input(0).filters = [SetPoint.new(0.2, 0.05)]
  gio.analog_input(0).add_event_listener(PortEvent::CHANGE) do |event|
    puts "ain 0: #{event.target.last_value} => #{event.target.value}"
  end

  gio.button.add_event_listener(PortEvent::RISING_EDGE) do
    puts "button: pressed"
  end

  gio.button.add_event_listener(PortEvent::FALLING_EDGE) do
    puts "button: released"
  end

  Osc.service_interval = 33
  blinker = Osc.new(Osc::SQUARE, 2.0, 0)
  gio.led.filters = [blinker]
  blinker.reset
  blinker.start

  sleep(5)
end
