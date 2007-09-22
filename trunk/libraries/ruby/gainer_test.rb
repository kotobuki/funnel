#!/usr/bin/env ruby

require "funnel"
require "gainer"

module Funnel
  AIN_0 = 0
  LED = 16
  BUTTON = 17

  fio = Funnel.new('localhost', 9000, GainerIO::MODE_1, 33)

  fio.port(AIN_0).filters = [SetPoint.new(0.5, 0.1)]
  fio.port(AIN_0).add_event_listener(PortEvent::CHANGE) do |event|
    puts "ain 0: #{event.target.last_value} => #{event.target.value}"
  end

  fio.port(BUTTON).add_event_listener(PortEvent::RISING_EDGE) do
    puts "button: pressed"
  end

  fio.port(BUTTON).add_event_listener(PortEvent::FALLING_EDGE) do
    puts "button: released"
  end

  Osc.service_interval = 33
  blinker = Osc.new(Osc::SQUARE, 2.0, 0)
  fio.port(LED).filters = [blinker]
  blinker.reset
  blinker.start

  sleep(5)
end
