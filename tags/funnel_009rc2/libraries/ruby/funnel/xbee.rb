#!/usr/bin/env ruby -wKU

require "funnel/iosystem"

module Funnel
  class XBee < IOSystem
    include IPAppletAdapter if defined? IRP

    ALL = IOSystem::ALL

    @@MULTIPOINT = Configuration.new(Configuration::XBEE, Configuration::MULTIPOINT)
    @@ZB = Configuration.new(Configuration::XBEE, Configuration::ZB)

    def self.MULTIPOINT
      return @@MULTIPOINT
    end

    def self.ZB
      return @@ZB
    end
    
    def initialize(arguments)
      # default values
      @config = @@MULTIPOINT
      nodes = nil
      host = '127.0.0.1'
      port = 9000
      interval = 33

      raise ArgumentError, "no arguments are supplied" if arguments == nil

      nodes = arguments[:nodes]
      host = arguments[:host] unless arguments[:host] == nil
      port = arguments[:port] unless arguments[:port] == nil
      interval = arguments[:interval] unless arguments[:interval] == nil
      autoregister = arguments[:autoregister] unless arguments[:autoregister] == nil
      @config = arguments[:config] unless arguments[:config] == nil
      applet = arguments[:applet]

      super(nil, host, port, interval, applet)

      @autoregister = autoregister
      @broadcast = IOModule.new(self, ALL, @config, "broadcast", true)
      nodes = [] if nodes == nil
      nodes.each do |id|
        register_node(id, "")
      end

      # Since we have not registered in the constructor, start polling manually
      begin
        send_command(OSC::Message.new('/polling', 'i', 1), true)
      rescue RuntimeError => e
        puts "RuntimeError occurred at start polling: #{e.message}"
      rescue TimeoutError => e
        puts "TimeoutError occurred at start polling: #{e.message}"
      end
    end
    
    def register_node(id, ni = "")
      add_io_module(id, @config, ni, false)
    end
  end
end
