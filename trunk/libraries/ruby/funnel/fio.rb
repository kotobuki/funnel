#!/usr/bin/env ruby -wKU

require "funnel/system"

module Funnel
  class Fio < System
    def initialize(host, port, interval = 33)
      super(host, port, interval)
      sleep(5)  # TODO: replace with proper implementation
    end
    
    def register_node(id, ni)
      add_module(id, Configuration.new(Configuration::FIO), ni)
    end
  end
end
