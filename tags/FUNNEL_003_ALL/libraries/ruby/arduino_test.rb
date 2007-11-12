#!/usr/bin/env ruby

require 'funnel'

module Funnel
  config = Configuration.new(ARDUINO)
  config.set_digital_pin_mode(11, PWM)
  config.set_digital_pin_mode(12, OUT)
  config.set_digital_pin_mode(13, OUT)
  aio = Funnel.new('localhost', 9000, config, 33)

  aio.analog_pin(0).filters = [SetPoint.new(0.5, 0.1)]
  aio.analog_pin(0).add_event_listener(PortEvent::CHANGE) do |event|
    puts "Analog 0: #{event.target.last_value} => #{event.target.value}"
  end

  aio.digital_pin(2).add_event_listener(PortEvent::CHANGE) do |event|
    puts "Digital 0: #{event.target.last_value} => #{event.target.value}"
  end

  Osc.service_interval = 20
  blinker = Osc.new(Osc::SQUARE, 2.0, 0)
  aio.digital_pin(13).filters = [blinker]
  blinker.reset
  blinker.start

  fader = Osc.new(Osc::SIN, 1.0, 0)
  scaler = Scaler.new(0.0, 1.0, 0.0, 1.0, Scaler::SQUARE)
  aio.digital_pin(11).filters = [fader, scaler]
  fader.reset
  fader.start

  sleep(5)
end
