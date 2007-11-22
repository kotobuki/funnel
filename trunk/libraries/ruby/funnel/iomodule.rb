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
    
    def initialize(parent, id, config, name = "")
      @parent = parent
      @id = id
      @port = []
      @port_count = 0
      @name = name

      init_ports(config.to_a)
      @updated_port_indices = Array.new(@port_count, false)
      @auto_update = true

      parent.send_command(OSC::Message.new('/configure', 'i' * (config.to_a.size + 1), id, *config.to_a))
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
  end
end
