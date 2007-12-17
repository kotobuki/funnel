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
    
    def initialize(nodes, host = 'localhost', port = 9000, interval = 33)
      super(nil, host, port, interval)
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
