#!/usr/bin/env ruby
$: << '..'

require 'funnel'

# broadcast to all nodes within the same PAN ID
module Funnel
  nodes = [2]
  fio = Fio.new(nodes)

  dimmer = Osc.new(Osc::SIN, 1.0, 0)
  fio.io_module(Fio::ALL).port(10).filters = [dimmer]
  dimmer.reset
  dimmer.start

  sleep(10)
end
