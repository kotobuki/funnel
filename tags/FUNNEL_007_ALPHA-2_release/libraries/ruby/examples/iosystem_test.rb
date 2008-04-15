#!/usr/bin/env ruby -wKU
$: << '..'

require 'funnel'

module Funnel
  config = Configuration.new(Configuration::GAINER, Configuration::MODE1)
  gio = IOSystem.new(config, 'localhost', 9000, 33)

  gio.io_module(0).port(0).filters = [SetPoint.new(0.5, 0.1)]
  gio.io_module(0).port(0).on PortEvent::CHANGE do |event|
    puts "ain 0: #{event.target.value}"
  end

  gio.io_module(0).port(17).on PortEvent::RISING_EDGE do
    puts "button: pressed"
  end

  gio.io_module(0).port(17).on PortEvent::FALLING_EDGE do
    puts "button: released"
  end

  Osc.service_interval = 33
  osc = Osc.new(Osc::SQUARE, 2.0, 0)
  gio.io_module(0).port(16).filters = [osc]
  osc.reset
  osc.start

  sleep(5)
end
