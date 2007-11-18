#!/usr/bin/env ruby -wKU

require "funnel/system"

module Funnel
  class XBee < System
    (XBS1, XBS2) = Array(0..1)
    
    def initialize(host, port, type = XBS1, interval = 33)
      super(host, port, interval)
      raise ArgumentError, "type #{type} is not available for XBee" if (type != XBS1) and (type != XBS2)
      @config = Configuration.new(Configuration::XBEE, type)
      sleep(5)  # TODO: replace with proper implementation
    end
    
    def register_node(id, ni)
      add_module(id, @config, ni)
    end
  end
end
