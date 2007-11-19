#!/usr/bin/env ruby -wKU

require "funnel/iosystem"

module Funnel
  class Fio < IOSystem
    def initialize(host, port, interval = 33)
      super(host, port, interval)
      sleep(5)  # TODO: replace with proper implementation
    end
    
    def register_node(id, ni)
      add_module(id, Configuration.new(Configuration::FIO), ni)
    end
  end
end
