#!/usr/bin/env ruby

require 'funnel'

module Funnel
  xbee = Funnel.new('localhost', 9000, Xbee::XBS1, 33)

  xbee.port(0).filters = [SetPoint.new(0.2, 0.05)]
  xbee.port(0).on PortEvent::CHANGE do |event|
    puts "AD0: #{event.target.last_value} => #{event.target.value}"
  end

  sleep(10)
end
