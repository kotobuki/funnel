#!/usr/bin/env ruby -wKU

require "funnel/system"

module Funnel
  class Gainer
    (MODE1, MODE2, MODE3, MODE4, MODE5, MODE6, MODE7, MODE8) = Array(1..8)

    def initialize(host, port, mode = MODE1, interval = 33)
      config = Configuration.new(Configuration::GAINER, mode)
      @system = System.new(host, port, interval, config)

      @ain_ports = config.ain_ports
      @din_ports = config.din_ports
      @aout_ports = config.aout_ports
      @dout_ports = config.dout_ports
      @button = config.button
      @led = config.led
    end

    def analog_input(number)
      return if @ain_ports == nil
      raise ArguentError, "analog input is not availabe at #{number}" if @ain_ports.at(number) == nil
      @system.iomodule(0).port(@ain_ports.at(number))
    end

    def digital_input(number)
      return if @din_ports == nil
      raise ArguentError, "digital input is not availabe at #{number}" if @din_ports.at(number) == nil
      @system.iomodule(0).port(@din_ports.at(number))
    end

    def analog_output(number)
      return if @aout_ports == nil
      raise ArguentError, "analog output is not availabe at #{number}" if @aout_ports.at(number) == nil
      @system.iomodule(0).port(@aout_ports.at(number))
    end

    def digital_output(number)
      return if @dout_ports == nil
      raise ArguentError, "digital output is not availabe at #{number}" if @dout_ports.at(number) == nil
      @system.iomodule(0).port(@dout_ports.at(number))
    end

    def button(number = 0)
      return if @button == nil
      raise ArguentError, "button is not availabe at #{number}" if @button.at(number) == nil
      @system.iomodule(0).port(@button.at(number))
    end

    def led(number = 0)
      return if @led == nil
      raise ArguentError, "LED is not availabe at #{number}" if @led.at(number) == nil
      @system.iomodule(0).port(@led.at(number))
    end

    alias :ain :analog_input
    alias :din :digital_input
    alias :aout :analog_output
    alias :dout :digital_output

  end

end
