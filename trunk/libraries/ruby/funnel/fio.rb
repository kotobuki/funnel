#!/usr/bin/env ruby -wKU

require "funnel/iosystem"

module Funnel
  class Fio < IOSystem
    ALL = IOSystem::ALL

    def initialize(host, port, autoregister = false, interval = 100)
      super(host, port, interval)
      @autoregister = autoregister
      @broadcast = IOModule.new(self, ALL, Configuration.new(Configuration::FIO), "broadcast")
    end
    
    def register_node(id, ni = "")
      add_module(id, Configuration.new(Configuration::FIO), ni)
    end
    
    def wait_for_nodes(number)
      50.times do
        break if @modules.length >= number
        sleep(0.1)
      end

      all_iomodules.each do |io|
        puts "fio: id: #{io.id}, name: #{io.name}"
      end
    end
  end
end
