#!/usr/bin/env ruby

require 'socket'
require 'timeout'
require 'osc'

require 'funneldefs'
require 'port'
require 'filter'

module Funnel
  class Funnel
    MINIMUM_SAMPLING_INTERVAL = 10

    def initialize(host, port, config, interval)
      @command_port = TCPSocket.open(host, port)
      puts "command port: #{@command_port.addr.at(2)}, #{@command_port.addr.at(1)}"
      @notification_port = TCPSocket.open(host, port + 1)
      puts "notification port: #{@notification_port.addr.at(2)}, #{@notification_port.addr.at(1)}"

      send_command(OSC::Message.new('/reset'))
      send_command(OSC::Message.new('/configure', 'i' * config.size, *config))
      @port = []
      @port_count = 0
      init_ports(config)

      if interval < MINIMUM_SAMPLING_INTERVAL
        then interval = MINIMUM_SAMPLING_INTERVAL
      end
      send_command(OSC::Message.new('/samplingInterval', 'i', interval))
      @sampling_interval = interval

      @auto_update = true

      Thread.new do
        loop do
          packet = @notification_port.recv(8192)
          begin
            OSC::Packet.decode(packet).each do |time, message|
              from = message.to_a[0]
              counts = message.to_a.length - 1
              counts.times do |i|
                port(from + i).value = message.to_a[1 + i]
              end
            end
          rescue EOFError
            puts "EOFError: packet = #{packet}"
            puts "(row bytes dump follows)"
            p packet
            exit
          end
        end
      end

      send_command(OSC::Message.new('/polling', 'i', 1))
    end

    def send_command(command)
      @command_port.send(command.encode, 0)
      packet = nil
      begin
        timeout(1) {packet = @command_port.recv(4096)}
        OSC::Packet.decode(packet).each do |time, message|
          puts "received: #{message.address}, #{message.to_a}"
        end
      rescue TimeoutError
        puts "TimeoutError: command = #{command.address}"
      rescue EOFError
        puts "EOFError: packet = #{packet}"
      end
    end

    def init_ports(config)
      @port.clear
      config.each do |type|
        puts "port(#{@port_count}): #{type}"
        port = Port.new(@port_count, type)
        @port.push(port)
        if port.direction == PortDirection::OUTPUT then
          port.add_event_listener(Event::CHANGE) do |event|
            puts "changed(#{event.from}): #{event.value}"
            if (@auto_update) then
              command = OSC::Message.new('/out', 'if', event.from, event.value)
              send_command(command)
            else
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


if __FILE__ == $0
  module Funnel
    fio = Funnel.new('localhost', 9000, GainerIO::MODE_1, 33)

    fio.port(0).filters = [SetPoint.new(0.5, 0.1)]
    fio.port(0).add_event_listener(Event::CHANGE) do |event|
      puts "ain 0: #{event.value}"
    end

    fio.port(17).add_event_listener(Event::CHANGE) do |event|
      puts "button: #{event.value}"
    end

    fio.port(17).add_event_listener(Event::RISING_EDGE) do
      puts "button: pressed"
    end

    fio.port(17).add_event_listener(Event::FALLING_EDGE) do
      puts "button: released"
    end

    3.times do
      fio.port(16).value = 1
      fio.port(16).value = 0
      sleep(0.1)
    end

    sleep(10)
  end
end
