#!/usr/bin/env ruby

require "serial_port"

class GainerIO < Funnel::SerialPort
  @receiver
  @dispatcher
  @quitRequested = false
  @commands = []

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

  def reboot
    reply = talk("Q", 2)
    sleep(0.1)
    return reply
  end

  def getVersion
    talk("?", 10)
  end

  def turnOnLED
#    talk("h", 2)
    talk("h", 0)
  end

  def turnOffLED
#    talk("l", 2)
    talk("l", 0)
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
    talk("i", 0)
  end

  def endAnalogInput
    talk("E", 0)
  end

  def startPolling
    received = ''
    commands = []

    @receiver = Thread.new do
      while !@quitRequested
        sleep(0.01) while (bytes_available < 1)

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

    @commands.each do |command|
      case command[0]
      when ?i
        values = command.unpack('xa2a2a2a2')
#        puts "ain: #{values.at(0).hex}, #{values.at(1).hex}, #{values.at(2).hex}, #{values.at(3).hex}"  # ain 0..3
      when ?h
        puts "led: on"
      when ?l
        puts "led: off"
      when ?N
        puts "sw: on"
      when ?F
        puts "sw: off"
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
