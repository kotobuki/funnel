#!/usr/bin/env ruby -wKU

require "funnel/iosystem"

module Funnel
  config = config = Configuration.new(FIO)
  gio = IOSystem.new('localhost', 9000, 33, config)

  gio.iomodule(0).port(0).filters = [SetPoint.new(0.5, 0.1)]
  gio.iomodule(0).port(0).add_event_listener(PortEvent::CHANGE) do |event|
    puts "ain 0: #{event.target.value}"
  end

  gio.iomodule(0).port(17).on(PortEvent::RISING_EDGE) do
    puts "button: pressed"
  end

  gio.iomodule(0).port(17).on PortEvent::FALLING_EDGE do
    puts "button: released"
  end

  Osc.service_interval = 33
  osc = Osc.new(Osc::SQUARE, 2.0, 0)
  gio.iomodule(0).port(16).filters = [osc]
  osc.reset
  osc.start

  sleep(5)
end
