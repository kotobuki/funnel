require 'thread'

require "serial_port"
require "funneldefs"

module Funnel
  class GainerIO < Funnel::SerialPort
    CONFIGURATION_1 = [
      PORT_AIN,   # 0
      PORT_AIN,   # 1
      PORT_AIN,   # 2
      PORT_AIN,   # 3
      PORT_DIN,   # 4
      PORT_DIN,   # 5
      PORT_DIN,   # 6
      PORT_DIN,   # 7
      PORT_AOUT,  # 8
      PORT_AOUT,  # 9
      PORT_AOUT,  # 10
      PORT_AOUT,  # 11
      PORT_DOUT,  # 12
      PORT_DOUT,  # 13
      PORT_DOUT,  # 14
      PORT_DOUT,  # 15
      PORT_DOUT,  # 16: LED
      PORT_DIN,   # 17: Button
    ]

    @service_thread = nil
    @quit_requested = false
    @commands = []
    @event_handler

    def initialize(port, baudrate)
      super(port, baudrate)
      @command_queue = Queue.new
      @led_events = Queue.new
      @aout_events = Queue.new
      @dout_events = Queue.new
      @version_events = Queue.new
      @reboot_events = Queue.new
      @config_events = Queue.new
      @ain_port_range = Range.new(0,3)
      @din_port_range = Range.new(4,7)
      @aout_port_range = Range.new(8,11)
      @dout_port_range = Range.new(12,15)
    end

    def onEvent=(handler)
      @event_handler = handler
    end

    def clear_receive_buffer
      if (bytes_available > 0) then
        rest = read(bytes_available)
      end
    end

    def reboot
      reply = ''
      @command_queue.push("Q")
      timeout(5) {reply = @reboot_events.pop}
      sleep(0.1)
      return reply
    end

    def getVersion
      reply = ''
      @command_queue.push("?")
      timeout(5) {reply = @version_events.pop}
      return reply
    end

    # values: [port, val1, val2...]
    def setOutputs(values)
      port = values.at(0)
      return if (port < 0) or (port > 17)
      values.shift
      values.each do |value|
        if @aout_port_range.include?(port) then
          analogOutput(port, value)
        elsif @dout_port_range.include?(port) then
          digitalOutput(port, value)
        elsif (port == 16) then
          if (value == 0) then
            turnOffLED
          else
            turnOnLED
          end
        end
        port += 1
      end
    end

    def turnOnLED
      @command_queue.push('h')
      timeout(0.1) {@led_events.pop} # do handle timeout here!!!
    end

    def turnOffLED
      @command_queue.push('l')
      timeout(0.1) {@led_events.pop} # do handle timeout here!!!
    end

    def analogOutput(port, value)
#      puts "aout: #{port}, #{value}"
      value = value * 255
      if value < 0 then value = 0
      elsif value > 255 then value = 255
      end
      @command_queue.push("a" + format("%X", port - @aout_port_range.first) + format("%02X", value))
      timeout(0.1) {@aout_events.pop} # do handle timeout here!!!
    end

    def digitalOutput(port, value)
      puts "dout: #{port}, #{value}"
      if value == 0 then
        @command_queue.push("L" + format("%01X", port - @dout_port_range.first))
      else
        @command_queue.push("H" + format("%01X", port - @dout_port_range.first))
      end
      timeout(0.1) {@dout_events.pop} # do handle timeout here!!!
    end

    def setConfiguration(config_data)
      p config_data
      config_num = 0
      if (CONFIGURATION_1 <=> config_data) == 0 then
        puts "CONFIGURATION_1"
        config_num = 1
      else
        puts "invalid configuration"
        raise ArgumentError, "invalid configuration"
      end
      reply = ''
      @command_queue.push("KONFIGURATION_#{config_num}")
      timeout(5) {reply = @config_events.pop}
      sleep(0.1)
      return reply
    end

    def beginAnalogInput
      @command_queue.push('i')
    end

    def endAnalogInput
      @command_queue.push('E')
    end

    def startPolling
      received = ''
      commands = []
      @quit_requested = false

      @service_thread = Thread.new do
        while !@quit_requested
          if !@command_queue.empty? then
            command_to_output = @command_queue.pop
            write(command_to_output + '*')
          end

          if (bytes_available < 1) then
            sleep(0.01)
            next
          end

          received << read(bytes_available)
          count = received.scan(/\*/).length
          commands = received.split(/\*/)

          @commands = []
          count.times do |i|
            @commands << commands.at(i) unless (commands.at(i) == nil)
          end

          dispatchEvents
          if (commands.at(count) == nil) then received = ''
          else received = commands.at(count)
          end
        end
      end
    end

    def dispatchEvents
      return if (@commands == nil)
      return if (@event_handler == nil)

      @commands.each do |command|
        case command[0]
        when ?i
          values = command.unpack('xa2a2a2a2')
          @event_handler.call(AIN_EVENT, [values.at(0).hex, values.at(1).hex, values.at(2).hex, values.at(3).hex])
        when ?R
          value = command.unpack('xa4')
          puts "#{value}"
          @event_handler.call(DIN_EVENT, [value.hex & 0x1, value.hex & 0x2, value.hex & 0x4, value.hex & 0x8])
        when ?h
          @led_events.push(NO_ERROR)
        when ?l
          @led_events.push(NO_ERROR)
        when ?a
          @aout_events.push(NO_ERROR)
        when ?H
          @dout_events.push(NO_ERROR)
        when ?L
          @dout_events.push(NO_ERROR)
        when ??
          @version_events.push(command)
        when ?Q
          @reboot_events.push(command)
        when ?K
          @config_events.push(command)
        when ?N
          @event_handler.call(BUTTON_EVENT, [1])
        when ?F
          @event_handler.call(BUTTON_EVENT, [0])
        when ?E
          # puts "endAnalogInput"
        else
          puts "unknown data: #{command[0].chr}"
        end
      end
    end

    def finishPolling
      @quit_requested = true
      @service_thread.join(1)
    end
  end
end
