#!/usr/bin/env ruby
require "socket"
require 'osc'

port = 7123

client = TCPSocket.open('localhost', port)
p client

xs = []
#xs << OSC::Message.new('/funnel/quit', nil)
xs << OSC::Message.new('/funnel/quit', nil)

xs.each do |x|
  #  client.write(x.encode)
  client.send(x.encode, 0)
  packet = client.recv(256)
  begin
    OSC::Packet.decode(packet).each do |time, message|
      puts "received: #{message.address}, #{message.to_a}"
    end
  rescue EOFError
    puts "EOFError: packet = #{packet}"
  end
end
