#!/usr/bin/env ruby
$: << '..'

require 'funnel'

# communicate with a specific node to get sensor values
module Funnel
  fio = Fio.new
  fio.register_node(2)

  fio.iomodule(2).port(0).on PortEvent::CHANGE do |event|
    s = sprintf("AD0: %5.3f %s", event.target.value, "*" * (event.target.value * 40))
    puts s
  end

  sleep(30)
end
