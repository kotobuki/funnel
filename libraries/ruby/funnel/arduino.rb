#!/usr/bin/env ruby -wKU

require "funnel/iosystem"

module Funnel
  class Arduino
    @@FIRMATA = Configuration.new Configuration::ARDUINO

    def self.FIRMATA
      return @@FIRMATA
    end

    def initialize(arguments = nil)
      # default values
      config = @@FIRMATA
      host = '127.0.0.1'
      port = 9000
      interval = 33

      raise ArgumentError, "no arguments are supplied" if arguments == nil

      config = arguments[:config] unless arguments[:config] == nil
      host = arguments[:host] unless arguments[:host] == nil
      port = arguments[:port] unless arguments[:port] == nil
      interval = arguments[:interval] unless arguments[:interval] == nil
      applet = arguments[:applet]

      @system = IOSystem.new(config, host, port, interval, applet)

      # @analog_pins = config.analog_pins
      # @digital_pins = config.digital_pins

      # set SetPoint filters to each digital inputs
      config.digital_pins.each do |i|
        @system.io_module(0).port(i).filters = [SetPoint.new(0.5, 0)] if config.to_a[i] == Port::DIN
      end
    end

    def analog_pin(number)
      return @system.io_module(0).analog_pin(number)
      # return if @analog_pins == nil
      # raise ArgumentError, "analog pin is not availabe at #{number}" if @analog_pins.at(number) == nil
      # @system.io_module(0).port(@analog_pins.at(number))
    end

    def digital_pin(number)
      return @system.io_module(0).digital_pin(number)
      # return if @digital_pins == nil
      # raise ArgumentError, "digital pin is not availabe at #{number}" if @digital_pins.at(number) == nil
      # @system.io_module(0).port(@digital_pins.at(number))
    end
  end
end
