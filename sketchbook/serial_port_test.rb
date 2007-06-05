#!/usr/bin/env ruby

require "gainer_io"

devices = []

Dir.foreach("/dev") do | deviceName |
  devices.push(deviceName) if (deviceName.index("cu.usbserial") == 0)
end

if (devices.size < 1) then
  raise "Can't find any I/O modules..."
end

gio = GainerIO.new('/dev/' + devices.at(0), 38400)

def onEvent(type, value)
  if (type == GainerIO::AIN_EVENT) then
#    p value
  else
    puts "#{type}: #{value}"
  end
end

gio.onEvent = method(:onEvent)

puts gio.reboot
puts gio.getVersion
puts gio.setConfiguration(1)

gio.beginAnalogInput
gio.startPolling

sleep(0.1)

1.times do
  gio.turnOnLED
  sleep(0.1)
  gio.turnOffLED
  sleep(0.1)
end

sleep(2)

3.times do
  gio.turnOnLED
  sleep(0.1)
  gio.turnOffLED
  sleep(0.1)
end

sleep(2)

1.times do
  gio.turnOnLED
  sleep(0.1)
  gio.turnOffLED
  sleep(0.1)
end

gio.finishPolling
gio.endAnalogInput
