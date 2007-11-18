#!/usr/bin/env ruby

require 'socket'
require 'timeout'
require 'osc'

require 'funnel/configuration'
require 'funnel/event'
require 'funnel/port'
require 'funnel/filter'
require 'funnel/iomodule'

module Funnel
  (GAINER, ARDUINO, XBEE, FIO) = Array(Configuration::GAINER..Configuration::FIO)
  (IN, OUT, PWM) = Array(Configuration::IN..Configuration::PWM)

  class System
    MINIMUM_SAMPLING_INTERVAL = 10

    attr_accessor :auto_update

    def initialize(host, port, interval, config = nil)
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

      send_command(OSC::Message.new('/reset'), 5)

      if interval < MINIMUM_SAMPLING_INTERVAL
        then interval = MINIMUM_SAMPLING_INTERVAL
      end
      send_command(OSC::Message.new('/samplingInterval', 'i', interval))
      @sampling_interval = interval

      @auto_update = true

      @modules = Hash::new
      add_module(0, config) unless config == nil  # add the first I/O module if specified

      Thread.new do
        loop do
          packet = @notification_port.recv(8192)
          begin
            OSC::Packet.decode(packet).each do |time, message|
              id = message.to_a[0]
              next if @modules[id] == nil
              from = message.to_a[1]
              counts = message.to_a.length - 2
              counts.times do |i|
                @modules[id].port(from + i).value = message.to_a[2 + i]
              end
            end
          rescue EOFError
            puts "notification port: EOF error"
          end
        end
      end

      send_command(OSC::Message.new('/polling', 'i', 1))
    end

    def add_module(id, config)
      @modules.delete(id) if @modules.has_key?(id)
      iomodule = IOModule.new(self, id, config)
      @modules[id] = iomodule
      #      send_command(OSC::Message.new('/configure', 'i' * config.to_a.size, *config.to_a))
      # TODO send config message to the server
    end

    def send_command(command, seconds_to_wait = 1)
      @command_port.send(command.encode, 0)
      packet = nil
      begin
        timeout(seconds_to_wait) {packet = @command_port.recv(4096)}
        OSC::Packet.decode(packet).each do |time, message|
          # puts "received: #{message.address}, #{message.to_a}"
          if message.to_a[0] < ErrorEvent::NO_ERROR then
            case message.to_a[0]
            when ErrorEvent::ERROR:
              puts "ERROR: #{message.to_a[1]}"
            when ErrorEvent::REBOOT_ERROR:
              raise REBOOT_ERROR, "REBOOT_ERROR: #{message.to_a[1]}"
            when ErrorEvent::CONFIGURATION_ERROR:
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

      @modules.each_pair do |id, iomodule|
        iomodule.updated_port_indices.each_with_index do |updated, index|
          if updated then
            output_values.push(iomodule.port[index].value)
            iomodule.updated_port_indices[index] = false
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

    def iomodule(id)
      raise ArgumentError, "I/O module is not available at #{id}" if @modules[id] == nil
      @modules[id]
    end

  end
end


if __FILE__ == $0
  module Funnel
    gio = System.new('localhost', 9000, 33, Gainer::MODE1)

    gio.iomodule(0).port(0).filters = [SetPoint.new(0.5, 0.1)]
    gio.iomodule(0).port(0).add_event_listener(PortEvent::CHANGE) do |event|
      puts "ain 0: #{event.target.value}"
    end

    gio.iomodule(0).port(17).on(PortEvent::RISING_EDGE) do
      puts "button: pressed"
    end

    gio.iomodule(0).port(17).on PortEvent::FALLING_EDGE do
      puts "button: released"
    end

    Osc.service_interval = 33
    osc = Osc.new(Osc::SQUARE, 2.0, 0)
    gio.iomodule(0).port(16).filters = [osc]
    osc.reset
    osc.start

    sleep(5)
  end
end
