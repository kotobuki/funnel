#!/usr/bin/env ruby -wKU

require "funnel/iosystem"

module Funnel
  class Gainer
    (MODE1, MODE2, MODE3, MODE4, MODE5, MODE6, MODE7, MODE8) = Array(1..8)

    def self.MODE1
      return MODE1
    end

    def self.MODE2
      return MODE2
    end

    def self.MODE3
      return MODE3
    end

    def self.MODE4
      return MODE4
    end

    def self.MODE5
      return MODE5
    end

    def self.MODE6
      return MODE6
    end

    def self.MODE7
      return MODE7
    end

    def self.MODE8
      return MODE8
    end

    def initialize(arguments = nil)
      mode = MODE1
      host = '127.0.0.1'
      port = 9000
      interval = 33

      if arguments != nil then
        mode = arguments[:mode] unless arguments[:mode] == nil
        host = arguments[:host] unless arguments[:host] == nil
        port = arguments[:port] unless arguments[:port] == nil
        interval = arguments[:interval] unless arguments[:interval] == nil
        applet = arguments[:applet]
      end

      config = Configuration.new(Configuration::GAINER, mode)
      @system = IOSystem.new(config, host, port, interval, applet)

      # set SetPoint filters to each digital inputs
      @system.io_module(0).button.filters = [SetPoint.new(0.5, 0)] unless config.button == nil
      config.din_ports.each do |i|
        @system.io_module(0).port(i).filters = [SetPoint.new(0.5, 0)]
      end
    end

    def analog_input(number)
      return @system.io_module(0).analog_input(number)
    end

    def digital_input(number)
      return @system.io_module(0).digital_input(number)
    end

    def analog_output(number)
      return @system.io_module(0).analog_output(number)
    end

    def digital_output(number)
      return @system.io_module(0).digital_output(number)
    end

    def button(number = 0)
      return @system.io_module(0).button(number)
    end

    def led(number = 0)
      return @system.io_module(0).led(number)
    end

    alias :ain :analog_input
    alias :din :digital_input
    alias :aout :analog_output
    alias :dout :digital_output
  end

end
