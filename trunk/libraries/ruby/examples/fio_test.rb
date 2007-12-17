#!/usr/bin/env ruby
$: << '..'

require 'funnel'

module Funnel
  nodes = [2]
  fio = Fio.new(nodes)

  fio.all_io_modules.each do |io|
    puts "fio: id: #{io.id}, name: #{io.name}"

    io.port(0).on PortEvent::CHANGE do |event|
      puts "node #{io.id} (#{io.name}): AD0: #{event.target.value}"
    end

    Osc.service_interval = 50
    dimmer = Osc.new(Osc::SIN, 1.0, 0)
    io.port(10).filters = [dimmer]
    dimmer.reset
    dimmer.start
  end

  sleep(10)
end
