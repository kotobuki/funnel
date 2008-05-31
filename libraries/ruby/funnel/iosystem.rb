#!/usr/bin/env ruby

require 'socket'
require 'timeout'
require 'osc'

require 'funnel/configuration'
require 'funnel/event'
require 'funnel/port'
require 'funnel/filter'
require 'funnel/iomodule'

if defined? IRP then
  begin
    # Load action-coding related libraries
    require 'java'
    require 'rplib.jar'
    include_class 'processing.core.PApplet'
    include_class 'IPAppletAdapter'
    puts "INFO: Ready to use the action-coding environment"
  rescue LoadError
    # It seems that action-coding environment is not available
  end
end

module Funnel
  (GAINER, ARDUINO, XBEE, FIO) = Array(Configuration::GAINER..Configuration::FIO)
#  (IN, OUT, PWM) = Array(Configuration::IN..Configuration::PWM)

  class IOSystem
    include IPAppletAdapter if defined? IRP

    MINIMUM_SAMPLING_INTERVAL = 10
    ALL = 0xFFFF

    attr_accessor :auto_update

    def initialize(config, host, port, interval, applet = nil)

      if applet != nil then
        @applet = applet
        @applet.registerDispose(self)
      end
      
      begin
        @command_port = TCPSocket.open(host, port)
        puts "command port: #{@command_port.addr.at(2)}, #{@command_port.addr.at(1)}"
      rescue
        raise RuntimeError, "can't connect to the command port (#{port}) of the funnel_server"
      end
      begin
        @notification_port = TCPSocket.open(host, port + 1)
        puts "notification port: #{@notification_port.addr.at(2)}, #{@notification_port.addr.at(1)}"
      rescue
        raise RuntimeError, "can't connect to the notification port (#{port + 1}) of the funnel_server"
      end

      begin
        send_command(OSC::Message.new('/reset'), 5)
      rescue RuntimeError => e
        puts "RuntimeError occurred: #{e.message}"
        begin
          send_command(OSC::Message.new('/reset'), 5)
          puts "Tried again rebooting and got success"
        rescue
          puts "ERROR: Failed to reboot twice!!!"
        end
      end

      if interval < MINIMUM_SAMPLING_INTERVAL
        then interval = MINIMUM_SAMPLING_INTERVAL
      end
      send_command(OSC::Message.new('/samplingInterval', 'i', interval))
      @sampling_interval = interval

      @auto_update = true

      @modules = Hash::new
      add_io_module(0, config) unless config == nil  # add the first I/O module if specified
      @broadcast = nil
      @autoregister = false

      @th = Thread.new do
        loop do
          packet = @notification_port.recv(8192)
          begin
            OSC::Packet.decode(packet).each do |time, message|
              case message.address
              when '/in'
                id = message.to_a[0]
                next if @modules[id] == nil
                from = message.to_a[1]
                counts = message.to_a.length - 2
                counts.times do |i|
                  @modules[id].port(from + i).value = message.to_a[2 + i]
                end
              when '/node'
                next unless @autoregister
                id = message.to_a[0]
                ni = message.to_a[1]
                register_node(id, ni)
              end
            end
          rescue EOFError
            puts "notification port: EOF error"
          end
        end
      end

      send_command(OSC::Message.new('/polling', 'i', 1))
    end

    def add_io_module(id, config, name ="")
      @modules.delete(id) if @modules.has_key?(id)
      io_module = IOModule.new(self, id, config, name)
      @modules[id] = io_module
    end

    def all_io_modules()
      @modules.values
    end

    def register_node(id, ni)
      # should be implemented in a derived class
    end

    def send_command(command, seconds_to_wait = 1)
      @command_port.send(command.encode, 0)
      packet = nil
      begin
        timeout(seconds_to_wait) {packet = @command_port.recv(4096)}
        OSC::Packet.decode(packet).each do |time, message|
          # puts "received: #{message.address}, #{message.to_a}"
          if message.to_a[0] < FunnelErrorEvent::NO_ERROR then
            case message.to_a[0]
            when FunnelErrorEvent::ERROR
              puts "ERROR: #{message.to_a[1]}"
            when FunnelErrorEvent::REBOOT_ERROR
              raise RuntimeError, "REBOOT_ERROR: #{message.to_a[1]}"
            when FunnelErrorEvent::CONFIGURATION_ERROR
              raise RuntimeError, "CONFIGURATION_ERROR: #{message.to_a[1]}"
            end
          end
        end
      rescue TimeoutError
        puts "TimeoutError: command = #{command.address}"
      rescue EOFError
        puts "EOFError: packet = #{packet}"
      end
    end

    def send_output_command(id, start, values)
      command = OSC::Message.new('/out', 'iif', id, start, *values)
      send_command(command)
    end

    def update()
      start = 0
      output_values = []
      was_updated = false

      @modules.each_pair do |id, io_module|
        io_module.updated_port_indices.each_with_index do |updated, index|
          if updated then
            output_values.push(io_module.port[index].value)
            io_module.updated_port_indices[index] = false
            start = index unless was_updated
          elsif was_updated then
            send_output_command(start, output_values) unless index == 0
            output_values = []
          end
          was_updated = updated
        end
        send_output_command(start, output_values)
      end
    end

    def io_module(id)
      if id == ALL then
        raise ArgumentError, "broadcast is not available for this type" if @broadcast == nil
        @broadcast
      else
        raise ArgumentError, "I/O module is not available at #{id}" if @modules[id] == nil
        @modules[id]
      end
    end

    def dispose
      puts "INFO: Disposing..."
      @th.join 1
      @command_port.close
      @notification_port.close
      puts "INFO: Disposed!"
    end
  end
end


if __FILE__ == $0
  module Funnel
    gio = IOSystem.new(Gainer::MODE1, '127.0.0.1', 9000, 33)

    gio.io_module(0).port(0).filters = [SetPoint.new(0.5, 0.1)]
    gio.io_module(0).port(0).add_event_listener(PortEvent::CHANGE) do |event|
      puts "ain 0: #{event.target.value}"
    end

    gio.io_module(0).port(17).on(PortEvent::RISING_EDGE) do
      puts "button: pressed"
    end

    gio.io_module(0).port(17).on PortEvent::FALLING_EDGE do
      puts "button: released"
    end

    Osc.service_interval = 33
    osc = Osc.new(Osc::SQUARE, 2.0, 0)
    gio.io_module(0).port(16).filters = [osc]
    osc.reset
    osc.start

    sleep(5)
  end
end
