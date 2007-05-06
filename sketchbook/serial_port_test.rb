#!/usr/bin/env ruby

require "serial_port"

class GainerIO < Funnel::SerialPort
  @receiver
  @dispatcher
  @quitRequested = false
  @commands

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
    talk("h", 2)
  end

  def turnOffLED
    talk("l", 2)
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
    @commands
    received = ''
    @receiver = Thread.new do
      while !@quitRequested
        sleep(0.01) if (bytes_available < 1)
        received = read(bytes_available)
        puts = received.split(/\s*\*\s*/)
#        loop do
#          puts index = received.index('*')
#          break if (index == nil)
#          puts received.slice!(0, index)
#        end
      end
    end
  end

  def finishPolling
    @quitRequested = true
    @receiver.join(1)
  end
end

gio = GainerIO.new('/dev/cu.usbserial-A30009cF', 38400)

puts gio.reboot
puts gio.getVersion
puts gio.setConfiguration(1)

3.times do
  gio.turnOnLED
  sleep(0.2)
  gio.turnOffLED
  sleep(0.2)
end

puts gio.beginAnalogInput
gio.startPolling

sleep(5)

puts gio.endAnalogInput
gio.finishPolling
