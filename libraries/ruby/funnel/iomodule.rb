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
      @sysex_listeners = Hash::new

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
      return if @config.ain_ports == nil
      raise ArgumentError, "analog input is not availabe" if @config.ain_ports == nil
      raise ArgumentError, "analog input is not availabe at #{number}" if @config.ain_ports.at(number) == nil
      @port[@config.ain_ports.at(number)]
    end

    def digital_input(number)
      return if @config.din_ports == nil
      raise ArgumentError, "digital input is not availabe" if @config.din_ports == nil
      raise ArgumentError, "digital input is not availabe at #{number}" if @config.din_ports.at(number) == nil
      @port[@config.din_ports.at(number)]
    end

    def analog_output(number)
      return if @config.aout_ports == nil
      raise ArgumentError, "analog output is not availabe" if @config.aout_ports == nil
      raise ArgumentError, "analog output is not availabe at #{number}" if @config.aout_ports.at(number) == nil
      @port[@config.aout_ports.at(number)]
    end

    def digital_output(number)
      return if @config.dout_ports == nil
      raise ArgumentError, "digital output is not availabe" if @config.dout_ports == nil
      raise ArgumentError, "digital output is not availabe at #{number}" if @config.dout_ports.at(number) == nil
      @port[@config.dout_ports.at(number)]
    end

    def button(number = 0)
      return if @config.button == nil
      raise ArgumentError, "button is not availabe" if @config.button == nil
      raise ArgumentError, "button is not availabe at #{number}" if @config.button.at(number) == nil
      @port[@config.button.at(number)]
    end

    def led(number = 0)
      return if @config.led == nil
      raise ArgumentError, "LED is not availabe" if @config.led == nil
      raise ArgumentError, "LED is not availabe at #{number}" if @config.led.at(number) == nil
      @port[@config.led.at(number)]
    end

    def analog_pin(number)
      return if @config.analog_pins == nil
      raise ArgumentError, "analog pin is not availabe" if @config.analog_pins == nil
      raise ArgumentError, "analog pin is not availabe at #{number}" if @config.analog_pins.at(number) == nil
      @port[@config.analog_pins.at(number)]
    end

    def digital_pin(number)
      return if @config.digital_pins == nil
      raise ArgumentError, "digital pin is not availabe" if @config.digital_pins == nil
      raise ArgumentError, "digital pin is not availabe at #{number}" if @config.digital_pins.at(number) == nil
      @port[@config.digital_pins.at(number)]
    end

    def send_sysex(command, message)
      @parent.send_command(OSC::Message.new('/sysex/request', 'i' * (message.to_a.size + 2), @id, command, *message.to_a), false)
    end

    def add_sysex_listener(i2c_device)
      @sysex_listeners[i2c_device.address] = i2c_device
    end

    def handle_sysex(data)
      # data should be: slave address, register, data0, data1...
      @sysex_listeners[data[0]].handle_sysex(data) unless @sysex_listeners[data[0]] == nil
    end

    alias :ain :analog_input
    alias :din :digital_input
    alias :aout :analog_output
    alias :dout :digital_output
    alias :a :analog_pin
    alias :d :digital_pin
  end
end
