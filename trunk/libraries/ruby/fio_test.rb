#!/usr/bin/env ruby

require 'funnel'

module Funnel
  fio = Funnel.new('localhost', 9000, Fio::FIO, 33)

  fio.analog_input(0).filters = [SetPoint.new(0.2, 0.05)]
  fio.analog_input(0).on PortEvent::CHANGE do |event|
    puts "ain 0: #{event.target.last_value} => #{event.target.value}"
  end

  Osc.service_interval = 50
  blinker = Osc.new(Osc::SIN, 1.0, 0)
  fio.analog_output(0).filters = [blinker]
  blinker.reset
  blinker.start

  sleep(300)
end
