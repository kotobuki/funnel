#!/usr/bin/env ruby

require 'funnel/xbee'

module Funnel
  xbee = XBee.new(XBee::XBS1)

  xbee.all_iomodules.each do |io|
    puts "xbee: id: #{io.id}, name: #{io.name}"

    io.port(0).add_event_listener(PortEvent::CHANGE) do |event|
      puts "AD0: #{event.target.value}"
    end
  end

  sleep(10)
end
