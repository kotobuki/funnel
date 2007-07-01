require 'thread'

require "serial_port"
require "funneldefs"

module Funnel
  class GainerIO < Funnel::SerialPort
    @receiver = nil
    @quitRequested = false
    @commands = []
    @eventHandler
    
    attr_reader :receiver

    def initialize(port, baudrate)
      super(port, baudrate)
      @command_queue = Queue.new
      @led_events = Queue.new
      @aout_events = Queue.new
      @dout_events = Queue.new
    end

    def talk(command, reply_length)
      write(command + '*')

      return nil if (reply_length < 1)

      10.times do
        break if (bytes_available == reply_length)
        sleep(0.01)
      end

      if (bytes_available >= reply_length) then read(reply_length)
      else return nil
      end
    end

    def onEvent=(handler)
      @eventHandler = handler
    end

    def reboot
      reply = talk("Q", 2)
      sleep(0.1)
      return reply
    end

    def getVersion
      talk("?", 10)
    end

    # values: [port, val1, val2...]
    def setOutputs(values)
      port = values.at(0)
      return if (port < 0) || (port > 17)
      values.shift
      values.each do |value|
        if (0 <= port and port < 4) then
          analogOutput(port, value)
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
      #    talk("h", 2)
#      talk("h", 0)
#      sleep(0.05)
      @command_queue.push('h')
      @led_events.pop # do handle timeout here!!!
    end

    def turnOffLED
      #    talk("l", 2)
#      talk("l", 0)
#      sleep(0.05)
      @command_queue.push('l')
      @led_events.pop # do handle timeout here!!!
    end

    def analogOutput(port, value)
      value = value * 255
      if value < 0 then value = 0
      elsif value > 255 then value = 255
      end
#      talk("a" + format("%X", port) + format("%02X", value), 0)
      @command_queue.push("a" + format("%X", port) + format("%02X", value))
      @aout_events.pop # do handle timeout here!!!
    end

    def setConfiguration(configuration)
      reply = talk("KONFIGURATION_#{configuration}", 16)
      sleep(0.1)
      return reply
    end

    def onEvent(i)
      puts "event: #{i}"
    end

    def beginAnalogInput
      @command_queue.push('i')
#      talk("i", 0)
    end

    def endAnalogInput
      @command_queue.push('E')
#      talk("E", 0)
    end

    def startPolling
      received = ''
      commands = []

      @receiver = Thread.new do
        while !@quitRequested
          if !@command_queue.empty? then
            command_to_output = @command_queue.pop
            write(command_to_output + '*')
          end

#          sleep(0.01) while (bytes_available < 1)
          next if (bytes_available < 1)

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
      return if (@eventHandler == nil)

      @commands.each do |command|
        case command[0]
        when ?i
          values = command.unpack('xa2a2a2a2')
          @eventHandler.call(AIN_EVENT, [values.at(0).hex, values.at(1).hex, values.at(2).hex, values.at(3).hex])
        when ?h
          @led_events.push(NO_ERROR)
        when ?l
          @led_events.push(NO_ERROR)
        when ?a
          @aout_events.push(NO_ERROR)
        when ?N
          @eventHandler.call(BUTTON_EVENT, [1])
        when ?F
          @eventHandler.call(BUTTON_EVENT, [0])
        else
          puts "unknown! #{command[0].chr}"
        end
      end
    end

    def finishPolling
      @quitRequested = true
      @receiver.join(1)
    end
  end
end