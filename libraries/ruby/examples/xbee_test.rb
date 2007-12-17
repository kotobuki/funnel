#!/usr/bin/env ruby
$: << '..'

require 'funnel'

module Funnel
  nodes = [2]
  xbee = XBee.new(nodes)

  xbee.all_iomodules.each do |io|
    puts "xbee: id: #{io.id}, name: #{io.name}"

    io.port(0).on PortEvent::CHANGE do |event|
      puts "AD0: #{event.target.value}"
    end
  end

  sleep(10)
end
