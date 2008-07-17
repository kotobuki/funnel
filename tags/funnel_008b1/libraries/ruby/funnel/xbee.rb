#!/usr/bin/env ruby -wKU

require "funnel/iosystem"

module Funnel
  class XBee < IOSystem
    (XBS1, XBS2) = Array(0..1)

    def self.XBS1
      return XBS1
    end

    def self.XBS2
      return XBS2
    end
    
    def initialize(arguments)
      # default values
      nodes = nil
      host = '127.0.0.1'
      port = 9000
      interval = 33

      nodes = arguments[:nodes]
      host = arguments[:host] unless arguments[:host] == nil
      port = arguments[:port] unless arguments[:port] == nil
      interval = arguments[:interval] unless arguments[:interval] == nil
      applet = arguments[:applet]

      super(nil, host, port, interval, applet)
      @config = Configuration.new(Configuration::XBEE, XBS1)
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
