#!/usr/bin/env ruby -wKU

require "funnel/iosystem"

module Funnel
  class Fio < IOSystem
    ALL = IOSystem::ALL

    def initialize(nodes, host = '127.0.0.1', port = 9000, interval = 100, autoregister = false)
      super(nil, host, port, interval)
      @autoregister = autoregister
      @broadcast = IOModule.new(self, ALL, Configuration.new(Configuration::FIO), "broadcast")
      nodes = [] if nodes == nil
      nodes.each do |id|
        register_node(id, "")
      end
    end
    
    def register_node(id, ni = "")
      add_io_module(id, Configuration.new(Configuration::FIO), ni)
    end
    
    def wait_for_nodes(number)
      50.times do
        break if @modules.length >= number
        sleep(0.1)
      end

      all_io_modules.each do |io|
        puts "fio: id: #{io.id}, name: #{io.name}"
      end
    end
  end
end
