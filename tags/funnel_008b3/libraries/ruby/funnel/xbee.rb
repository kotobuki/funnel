#!/usr/bin/env ruby -wKU

require "funnel/iosystem"

module Funnel
  class XBee < IOSystem
    (MULTIPOINT, ZNET) = Array(0..1)

    def self.MULTIPOINT
      return MULTIPOINT
    end

    def self.ZNET
      return ZNET
    end
    
    def initialize(arguments)
      # default values
      @config = nil
      nodes = nil
      host = '127.0.0.1'
      port = 9000
      interval = 33

      raise ArgumentError, "no arguments are supplied" if arguments == nil

      @config = Configuration.new Configuration::XBEE, arguments[:config] unless arguments[:config] == nil
      nodes = arguments[:nodes]
      host = arguments[:host] unless arguments[:host] == nil
      port = arguments[:port] unless arguments[:port] == nil
      interval = arguments[:interval] unless arguments[:interval] == nil
      applet = arguments[:applet]

      super(@config, host, port, interval, applet)
      nodes = [] if nodes == nil
      nodes.each do |id|
        register_node(id, "")
      end
    end
    
    def register_node(id, ni)
      add_module(id, @config, ni)
    end
  end
end
