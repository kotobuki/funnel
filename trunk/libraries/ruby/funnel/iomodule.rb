#!/usr/bin/env ruby -wKU

require 'funnel/configuration'
require 'funnel/event'
require 'funnel/port'
require 'funnel/filter'

module Funnel
  class IOModule
    
    attr_accessor :updated_port_indices
    attr_accessor :auto_update
    attr_reader :id
    attr_reader :name
    
    def port_def_to_str(type)
      case type
      when Port::AIN
        return "analog input"
      when Port::DIN
        return "digital input"
      when Port::AOUT
        return "analog output (PWM)"
      when Port::DOUT
        return "digital output"
      end
    end
    
    def initialize(parent, id, config, name = "", do_configure = true)
      @parent = parent
      @id = id
      @config = config
      @port = []
      @port_count = 0
      @name = name

      init_ports(@config.to_a)
      @updated_port_indices = Array.new(@port_count, false)
      @auto_update = true

      return unless do_configure

      begin
        parent.send_command(OSC::Message.new('/configure', 'i' * (config.to_a.size + 1), id, *config.to_a), true)
      rescue RuntimeError => e
        puts "RuntimeError occurred at configuration: #{e.message}"
      rescue TimeoutError => e
        puts "TimeoutError occurred at configuration: #{e.message}"
      end
    end
      
    def init_ports(config)
      @port.clear
      config.each do |type|
#        puts "port(#{@port_count}): #{port_def_to_str(type)}"
        port = Port.new(@port_count, type)
        @port.push(port)
        if port.type == Port::AOUT or port.type == Port::DOUT then
          port.add_event_listener(PortEvent::CHANGE) do |event|
            if (@auto_update) then
              @parent.send_output_command(@id, event.target.number, event.target.value)
            else
              @updated_port_indices[event.target.number] = true
            end
          end
        end
        @port_count = @port_count + 1
      end
      @max_port_number = @port_count - 1
    end

    def port(number)
      if (number < 0) or (number > @max_port_number) then
        raise ArgumentError, "port is not available at #{number}"
        return nil
      end
      @port[number]
    end

    def analog_input(number)
      return if @ain_ports == nil
      raise ArguentError, "analog input is not availabe at #{number}" if @ain_ports.at(number) == nil
      @port[@ain_ports.at(number)]
    end

    def digital_input(number)
      return if @din_ports == nil
      raise ArguentError, "digital input is not availabe at #{number}" if @din_ports.at(number) == nil
      @port[@din_ports.at(number)]
    end

    def analog_output(number)
      return if @aout_ports == nil
      raise ArguentError, "analog output is not availabe at #{number}" if @aout_ports.at(number) == nil
      @port[@aout_ports.at(number)]
    end

    def digital_output(number)
      return if @dout_ports == nil
      raise ArguentError, "digital output is not availabe at #{number}" if @dout_ports.at(number) == nil
      @port[@dout_ports.at(number)]
    end

    def button(number = 0)
      return if @button == nil
      raise ArguentError, "button is not availabe at #{number}" if @button.at(number) == nil
      @port[@button.at(number)]
    end

    def led(number = 0)
      return if @led == nil
      raise ArguentError, "LED is not availabe at #{number}" if @led.at(number) == nil
      @port[@led.at(number)]
    end

    def analog_pin(number)
      return if @analog_pins == nil
      raise ArguentError, "analog pin is not availabe at #{number}" if @analog_pins.at(number) == nil
      @port[@analog_pins.at(number)]
    end

    def digital_pin(number)
      return if @digital_pins == nil
      raise ArguentError, "digital pin is not availabe at #{number}" if @digital_pins.at(number) == nil
      @port[@digital_pins.at(number)]
    end

    alias :ain :analog_input
    alias :din :digital_input
    alias :aout :analog_output
    alias :dout :digital_output
    alias :a :analog_pin
    alias :d :digital_pin
  end
end
