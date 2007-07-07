require 'thread'

require "serial_port"
require "funneldefs"

module Funnel
  class GainerIO < SerialPort
    LED_PORT = 16
    BUTTON_PORT = 17

    CONFIGURATION_1 = [
      PORT_AIN, PORT_AIN, PORT_AIN, PORT_AIN,
      PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN,
      PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT,
      PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT,
      PORT_DOUT, PORT_DIN  # LED, BUTTON
    ]

    CONFIGURATION_2 = [
      PORT_AIN, PORT_AIN, PORT_AIN, PORT_AIN,
      PORT_AIN, PORT_AIN, PORT_AIN, PORT_AIN,
      PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT,
      PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT,
      PORT_DOUT, PORT_DIN  # LED, BUTTON
    ]

    CONFIGURATION_3 = [
      PORT_AIN, PORT_AIN, PORT_AIN, PORT_AIN,
      PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN,
      PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT,
      PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT,
      PORT_DOUT, PORT_DIN  # LED, BUTTON
    ]

    CONFIGURATION_4 = [
      PORT_AIN, PORT_AIN, PORT_AIN, PORT_AIN,
      PORT_AIN, PORT_AIN, PORT_AIN, PORT_AIN,
      PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT,
      PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT,
      PORT_DOUT, PORT_DIN  # LED, BUTTON
    ]

    CONFIGURATION_5 = [
      PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN,
      PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN,
      PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN,
      PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN,
    ]

    CONFIGURATION_6 = [
      PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT,
      PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT,
      PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT,
      PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT,
    ]

    CONFIGURATION_7 = [
      PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, # [0..7, 0]
      PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, # [0..7, 1]
      PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, # [0..7, 2]
      PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, # [0..7, 3]
      PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, # [0..7, 4]
      PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, # [0..7, 5]
      PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, # [0..7, 6]
      PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, # [0..7, 7]
    ]

    CONFIGURATION_8 = [
      PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN,
      PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN,
      PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT,
      PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT,
    ]

    attr_reader :input

    @service_thread = nil
    @quit_requested = false
    @commands = []
    @event_handler
    @input = []
    @configuration = 0

    def initialize(port, baudrate)
      super(port, baudrate)
      @command_queue = Queue.new
      @led_events = Queue.new
      @aout_events = Queue.new
      @dout_events = Queue.new
      @version_events = Queue.new
      @reboot_events = Queue.new
      @config_events = Queue.new
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
      values.shift
      values.each do |value|
        if @aout_port_range.include?(port) then
          analogOutput(port, value)
        elsif @dout_port_range.include?(port) then
          digitalOutput(port, value)
        elsif @configuration <= 4 and port == LED_PORT then
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
      if @configuration == 7 then
        value = value * 16
        if value < 0 then value = 0
        elsif value > 15 then value = 15
        end
        8.times do |y|
          command = "a" + format("%X", y)
          line = value[y * 8, 8]
          line.size.times {|x| command << format("%01X", line.at(x))}
          @command_queue.push(command)
          timeout(0.1) {@aout_events.pop}
        end
      else
        value = value * 255
        if value < 0 then value = 0
        elsif value > 255 then value = 255
        end
        @command_queue.push("a" + format("%X", port - @aout_port_range.first) + format("%02X", value))
        timeout(0.1) {@aout_events.pop} # do handle timeout here!!!
      end
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
      if (CONFIGURATION_1 <=> config_data) == 0 then
        @configuration = 1
        @ain_port_range = Range.new(0, 3)
        @din_port_range = Range.new(4, 7)
        @aout_port_range = Range.new(8, 11)
        @dout_port_range = Range.new(12, 15)
        @input = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]   # 18 ports
        @ain_ports = 4
        @din_ports = 4
      elsif (CONFIGURATION_2 <=> config_data) == 0 then
        @configuration = 2
        @ain_port_range = Range.new(0, 7)
        @din_port_range = nil
        @aout_port_range = Range.new(8, 11)
        @dout_port_range = Range.new(12, 15)
        @input = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]   # 18 ports
        @ain_ports = 8
        @din_ports = 0
      elsif (CONFIGURATION_3 <=> config_data) == 0 then
        @configuration = 3
        @ain_port_range = Range.new(0, 3)
        @din_port_range = Range.new(4, 7)
        @aout_port_range = Range.new(8, 15)
        @dout_port_range = nil
        @input = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]   # 18 ports
        @ain_ports = 4
        @din_ports = 4
      elsif (CONFIGURATION_4 <=> config_data) == 0 then
        @configuration = 4
        @ain_port_range = Range.new(0, 7)
        @din_port_range = nil
        @aout_port_range = Range.new(8, 15)
        @dout_port_range = nil
        @input = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]   # 18 ports
        @ain_ports = 8
        @din_ports = 0
      elsif (CONFIGURATION_5 <=> config_data) == 0 then
        @configuration = 5
        @ain_port_range = nil
        @din_port_range = Range.new(0, 15)
        @aout_port_range = nil
        @dout_port_range = nil
        @input = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]   # 16 ports
        @ain_ports = 0
        @din_ports = 16
      elsif (CONFIGURATION_6 <=> config_data) == 0 then
        @configuration = 6
        @ain_port_range = nil
        @din_port_range = nil
        @aout_port_range = nil
        @dout_port_range = Range.new(0, 15)
        @input.clear
        @ain_ports = 0
        @din_ports = 0
      elsif (CONFIGURATION_7 <=> config_data) == 0 then
        @configuration = 7
        @ain_port_range = nil
        @din_port_range = nil
        @aout_port_range = Range.new(0, 63)
        @dout_port_range = nil
        @input.clear
        @ain_ports = 0
        @din_ports = 0
      elsif (CONFIGURATION_8 <=> config_data) == 0 then
        @configuration = 8
        @ain_port_range = nil
        @din_port_range = Range.new(0, 7)
        @aout_port_range = nil
        @dout_port_range = Range.new(8, 15)
        @input = [0, 0, 0, 0, 0, 0, 0, 0]
        @ain_ports = 0
        @din_ports = 8
      else
        puts "Invalid configuration!"
        raise ArgumentError, "Invalid configuration"
      end
      puts "Requested configuration: #{@configuration}"
      reply = ''
      @command_queue.push("KONFIGURATION_#{@configuration}")
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
          values = command.unpack('x' + 'a2' * @ain_ports)
          offset = @ain_port_range.first
          @ain_ports.times {|i| @input[offset + i] = values.at(i).hex / 255.0}   # convert from integer to float
          @event_handler.call(offset, @input[offset, @ain_ports])
        when ?R
          val = command.unpack('xa4').at(0).hex
          offset = @din_port_range.first
          @din_ports.times {|i| @input[offset + i] = val[i]}   # convert from bit to integer
          @event_handler.call(offset, @input[offset, @din_ports])
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
          @input[BUTTON_PORT] = 1
          @event_handler.call(BUTTON_PORT, @input[BUTTON_PORT, 1])
        when ?F
          @input[BUTTON_PORT] = 0          
          @event_handler.call(BUTTON_PORT, @input[BUTTON_PORT, 1])
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
