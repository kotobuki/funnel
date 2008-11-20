#!/usr/bin/env ruby -wKU

require "funnel/iosystem"

module Funnel
  class Arduino
    @@FIRMATA = Configuration.new Configuration::ARDUINO

    def self.FIRMATA
      return @@FIRMATA
    end

    def initialize(arguments = nil)
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

      # set SetPoint filters to each digital inputs
      config.digital_pins.each do |i|
        @system.io_module(0).port(i).filters = [SetPoint.new(0.5, 0)] if config.to_a[i] == Port::DIN
      end
    end

    def analog_pin(number)
      return @system.io_module(0).analog_pin(number)
    end

    def digital_pin(number)
      return @system.io_module(0).digital_pin(number)
    end

    def send_sysex(command, message)
      return @system.io_module(0).send_sysex(command, message)
    end

    def add_sysex_listener(i2c_device)
      @system.io_module(0).add_sysex_listener(i2c_device)
    end
    
    alias :a :analog_pin
    alias :d :digital_pin
  end
end
