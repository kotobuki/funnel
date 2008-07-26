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
      # default values
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

      @ain_ports = config.ain_ports
      @din_ports = config.din_ports
      @aout_ports = config.aout_ports
      @dout_ports = config.dout_ports
      @button = config.button
      @led = config.led

      button.filters = [SetPoint.new(0.5, 0)] unless @button == nil
    end

    def analog_input(number)
      return if @ain_ports == nil
      raise ArguentError, "analog input is not availabe at #{number}" if @ain_ports.at(number) == nil
      @system.io_module(0).port(@ain_ports.at(number))
    end

    def digital_input(number)
      return if @din_ports == nil
      raise ArguentError, "digital input is not availabe at #{number}" if @din_ports.at(number) == nil
      @system.io_module(0).port(@din_ports.at(number))
    end

    def analog_output(number)
      return if @aout_ports == nil
      raise ArguentError, "analog output is not availabe at #{number}" if @aout_ports.at(number) == nil
      @system.io_module(0).port(@aout_ports.at(number))
    end

    def digital_output(number)
      return if @dout_ports == nil
      raise ArguentError, "digital output is not availabe at #{number}" if @dout_ports.at(number) == nil
      @system.io_module(0).port(@dout_ports.at(number))
    end

    def button(number = 0)
      return if @button == nil
      raise ArguentError, "button is not availabe at #{number}" if @button.at(number) == nil
      @system.io_module(0).port(@button.at(number))
    end

    def led(number = 0)
      return if @led == nil
      raise ArguentError, "LED is not availabe at #{number}" if @led.at(number) == nil
      @system.io_module(0).port(@led.at(number))
    end

    alias :ain :analog_input
    alias :din :digital_input
    alias :aout :analog_output
    alias :dout :digital_output

  end

end
