#!/usr/bin/env ruby
$: << '..'

require 'funnel'
include Funnel

# communicate with a specific node to get a button status
nodes = [1]
@fio = Fio.new(nodes)

sleep 2

@fio.io_module(1).port(17).value = 1

@fio.io_module(1).port(16).on RISING_EDGE do
  puts 'ON!'
end

@fio.io_module(1).port(16).on FALLING_EDGE do
  puts 'OFF'
end

sleep 5
