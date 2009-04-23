#!/usr/bin/env ruby

# === Overview
# A simple example for XBee I/O modules
# [Author] Shigeru Kobayashi
# [License] The new BSD license
# === Operating environment
# * a XBee Multipoint wireless module
# * a sensor (e.g. photocell, potentiometer)
# * Funnel 008 or later
# * Ruby 1.8.6
# === Connection
# * AD0: a sensor

$: << '..'

require 'funnel'
include Funnel

config = XBee.MULTIPOINT
nodes = [1]
xbee = XBee.new :config => config, :nodes => nodes

xbee.all_io_modules.each do |io|
  puts "xbee: id: #{io.id}, name: #{io.name}"

  io.pin(0).on CHANGE do |event|
    puts "AD0: #{event.target.value}"
  end
end

sleep(10)
