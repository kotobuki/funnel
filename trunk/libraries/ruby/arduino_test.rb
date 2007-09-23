#!/usr/bin/env ruby

require "funnel"

module Funnel
  ANALOG_0 = 0
  DIGITAL_2 = 8
  DIGITAL_11 = 17
  DIGITAL_13 = 19

  config = [
    0, 0, 0, 0, 0, 0,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 3, 3
  ]

  fio = Funnel.new('localhost', 9000, config, 33)

  fio.port(ANALOG_0).filters = [SetPoint.new(0.5, 0.1)]
  fio.port(ANALOG_0).add_event_listener(PortEvent::CHANGE) do |event|
    puts "Analog 0: #{event.target.last_value} => #{event.target.value}"
  end

  fio.port(DIGITAL_2).add_event_listener(PortEvent::CHANGE) do |event|
    puts "Digital 0: #{event.target.last_value} => #{event.target.value}"
  end

  Osc.service_interval = 20
  blinker = Osc.new(Osc::SQUARE, 2.0, 0)
  fio.port(DIGITAL_13).filters = [blinker]
  blinker.reset
  blinker.start

  fader = Osc.new(Osc::SIN, 1.0, 0)
  scaler = Scaler.new(0.0, 1.0, 0.0, 1.0, Scaler::SQUARE)
  fio.port(DIGITAL_11).filters = [fader, scaler]
  fader.reset
  fader.start

  sleep(5)
end
