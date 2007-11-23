#!/usr/bin/env ruby

require "funnel/fio"

# broadcast to all found nodes
module Funnel
  fio = Fio.new('localhost', 9000, true)
  fio.wait_for_nodes(2)

  dimmer = Osc.new(Osc::SIN, 1.0, 0)
  fio.iomodule(Fio::ALL).port(10).filters = [dimmer]
  dimmer.reset
  dimmer.start

  sleep(10)
end
