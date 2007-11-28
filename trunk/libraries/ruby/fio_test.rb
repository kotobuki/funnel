#!/usr/bin/env ruby

require "funnel/fio"

module Funnel
  fio = Fio.new

  fio.all_iomodules.each do |io|
    puts "fio: id: #{io.id}, name: #{io.name}"

#    io.port(0).filters = [SetPoint.new(0.5, 0.1)]
    io.port(0).add_event_listener(PortEvent::CHANGE) do |event|
      puts "node #{io.id} (#{io.name}): ain 0: #{event.target.value}"
    end

    Osc.service_interval = 50
    dimmer = Osc.new(Osc::SIN, 1.0, 0)
    io.port(10).filters = [dimmer]
    dimmer.reset
    dimmer.start
  end

  sleep(10)
end
