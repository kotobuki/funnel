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
    attr_accessor :autoregister
    attr_accessor :broadcast

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

      @command_queue = Queue.new

      @th = Thread.new do
        loop do
          data = @command_port.recv(8192)
          processed_size = 0
          while processed_size < data.length do
            packet_size = data.slice(processed_size, 4).unpack('N').at(0)
            packet = data.slice(processed_size + 4, packet_size)

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
                when '/configure'
                  if message.to_a[0] == FunnelErrorEvent::CONFIGURATION_ERROR then
                    # raise RuntimeError, "CONFIGURATION_ERROR: #{message.to_a[1]}"
                    puts "CONFIGURATION_ERROR: #{message.to_a[1]}"
                  else
                    puts "Configured successfully"
                    @command_queue.push message
                  end
                when '/reset'
                  if message.to_a[0] == FunnelErrorEvent::REBOOT_ERROR then
                    # raise RuntimeError, "REBOOT_ERROR: #{message.to_a[1]}"
                    puts "REBOOT_ERROR: #{message.to_a[1]}"
                  else
                    puts "Rebooted successfully"
                    @command_queue.push message
                  end
                when '/samplingInterval'
                when '/polling'
                  if message.to_a[0] == FunnelErrorEvent::ERROR then
                    puts "ERROR: #{message.address}, #{message.to_a[1]}"
                  else
                    puts "OK: #{message.address}"
                    @command_queue.push message
                  end
                when '/out'
                  puts "ERROR: #{message.address}" if message.to_a[0] < FunnelErrorEvent::NO_ERROR
                when '/sysex'
                  case message.to_a[1]
                  when 0x76
                    @modules[message.to_a[0]].handle_sysex(message.to_a[2..(message.to_a.size - 1)]) unless @modules[message.to_a[0]] == nil
                  when 0x71
                    puts "Firmata String (at #{message.to_a[0]}): #{message.to_a[2]}"
                  end
                end
              end
            rescue EOFError
              puts "notification port: EOF error"
            end
            processed_size += packet_size + 4
          end
        end
      end

      begin
        send_command(OSC::Message.new('/reset'), true)
      rescue RuntimeError => e
        puts "RuntimeError occurred: #{e.message}"
        begin
          send_command(OSC::Message.new('/reset'), true)
          puts "Tried again rebooting and got success"
        rescue
          puts "ERROR: Failed to reboot twice!!!"
        end
      rescue TimeoutError => e
        puts "TimeoutError occurred: #{e.message}"
      end

      if interval < MINIMUM_SAMPLING_INTERVAL
        then interval = MINIMUM_SAMPLING_INTERVAL
      end
      # begin
      #   send_command(OSC::Message.new('/samplingInterval', 'i', interval), true)
      # rescue RuntimeError => e
      #   puts "RuntimeError occurred at setting the sampling interval: #{e.message}"
      # rescue TimeoutError => e
      #   puts "TimeoutError occurred at setting the sampling interval: #{e.message}"
      # end

      @sampling_interval = interval

      @auto_update = true
      @modules = Hash::new
      add_io_module(0, config) unless config == nil  # add the first I/O module if specified
      @broadcast = nil
      @autoregister = false

      return if config == nil

      begin
        send_command(OSC::Message.new('/polling', 'i', 1), true)
      rescue RuntimeError => e
        puts "RuntimeError occurred at start polling: #{e.message}"
      rescue TimeoutError => e
        puts "TimeoutError occurred at start polling: #{e.message}"
      end
    end

    def add_io_module(id, config, name = "", do_configure = true)
      @modules.delete(id) if @modules.has_key?(id)
      io_module = IOModule.new(self, id, config, name, do_configure)
      @modules[id] = io_module
    end

    def all_io_modules()
      @modules.values
    end

    def register_node(id, ni)
      # should be implemented in a derived class
    end

    def send_command(command, synchronized = false, time_limit = 1)
      encoded = command.encode
      data = [encoded.length].pack('N') + encoded
      @command_port.send(data, 0)
      @command_port.flush
      if synchronized then
        reply = nil
        start_time = Time.now.to_f
        while reply == nil do
          begin
            reply = @command_queue.pop(true)
          rescue ThreadError
            sleep 0.1
            raise TimeoutError, "Got no reply for #{command.address}" if (Time.now.to_f - start_time) > time_limit
          end
        end
        raise RuntimeError, "Expected reply was #{command.address}, but is #{reply.address}" if command.address != reply.address
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
      Osc.dispose
      @th.join 1
      @command_port.close
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
