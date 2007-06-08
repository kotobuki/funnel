#!/usr/bin/env ruby

require "socket"
require 'osc'

port = 7123

@client = TCPSocket.open('localhost', port)
p @client

@xs = []

def send_commands
  @xs.each do |x|
    p x
    @client.send(x.encode, 0)
    packet = @client.recv(256)
    begin
      OSC::Packet.decode(packet).each do |time, message|
        puts "received: #{message.address}, #{message.to_a}"
      end
    rescue EOFError
      puts "EOFError: packet = #{packet}"
    end
  end
  @xs = []
end

@xs << OSC::Message.new('/reset', nil)
@xs << OSC::Message.new('/out', 'i', 17, 1)
@xs << OSC::Message.new('/polling', 'i', 1)
send_commands

2000.times do
  command = OSC::Message.new('/in', 'i', 0)
  @client.send(command.encode, 0)
  packet = @client.recv(256)
  begin
    OSC::Packet.decode(packet).each do |time, message|
      puts "received: #{message.address}, #{message.to_a}"
    end
  rescue EOFError
    puts "EOFError: packet = #{packet}"
  end
  sleep(0.01)
end

@xs << OSC::Message.new('/polling', 'i', 0)
@xs << OSC::Message.new('/out', 'i', 17, 0)
@xs << OSC::Message.new('/quit', nil)
send_commands
