#!/usr/bin/env ruby -wKU

require "funnel/iosystem"

module Funnel
  class XBee < IOSystem
    (XBS1, XBS2) = Array(0..1)
    
    def initialize(type = XBS1, host = 'localhost', port = 9000, interval = 33)
      super(nil, host, port, interval)
      raise ArgumentError, "type #{type} is not available for XBee" if (type != XBS1) and (type != XBS2)
      @config = Configuration.new(Configuration::XBEE, type)
      sleep(5)  # TODO: replace with proper implementation
    end
    
    def register_node(id, ni)
      add_module(id, @config, ni)
    end
  end
end
