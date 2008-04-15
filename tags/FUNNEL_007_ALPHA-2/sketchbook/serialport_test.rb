#!/usr/bin/env ruby

require "serial_port"

#@sp = Funnel::SerialPort.new('COM3', 38400)
@sp = Funnel::SerialPort.new('/dev/cu.usbserial-A30009cb', 38400)

def talk(command, length)
  @sp.write(command)
  while @sp.bytes_available < length do
    sleep(0.001)
  end
  @sp.read(length)
end

p talk('Q*', 2)
sleep(0.1)
p talk('?*', 10)
p talk('KONFIGURATION_1*', 16)
sleep(0.1)

puts "*** 2 bytes version ***"
start = Time.now
1000.times do
  talk('h*', 2)
  talk('l*', 2)
end
finish = Time.now
puts "#{1000 / (finish - start)} fps"

puts ""

sleep(1)

def padding(s, packetsize)
  s + ("\000" * (packetsize - s.size))
end

on = padding('h*', 62)
off = padding('l*', 62)

puts "*** #{on.size} bytes version ***"
start = Time.now
1000.times do
  talk(on, 2)
  talk(off, 2)
end
finish = Time.now
puts "#{1000 / (finish - start)} fps"

# 38400bps = 3840cps
# 64 / 3840 = 16ms
# 1000 / (16 + 16) = 32 fps

# 115000bps = 11500cps
# 64 / 11500 = 6ms
# 1000 / (6 + 6) = 83 fps
