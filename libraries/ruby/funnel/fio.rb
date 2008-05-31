#!/usr/bin/env ruby -wKU

require "funnel/iosystem"

module Funnel
  class Fio < IOSystem
    ALL = IOSystem::ALL

    def initialize(arguments)
      # default values
      nodes = nil
      host = '127.0.0.1'
      port = 9000
      interval = 33
      autoregister = false

      nodes = arguments[:nodes]
      host = arguments[:host] unless arguments[:host] == nil
      port = arguments[:port] unless arguments[:port] == nil
      interval = arguments[:interval] unless arguments[:interval] == nil
      autoregister = arguments[:autoregister] unless arguments[:autoregister] == nil
      applet = arguments[:applet]
      
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
      io_module(id).port(16).filters = [SetPoint.new(0.5, 0)] unless id == ALL
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
