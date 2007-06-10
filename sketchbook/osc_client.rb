#!/usr/bin/env ruby

require "socket"
require 'osc'

port = 5000

@client = TCPSocket.open('localhost', port)
@receiver = TCPSocket.open('localhost', port + 1)
p @client

@xs = []

def send_commands
  @xs.each do |x|
    p x
    @client.send(x.encode, 0)
    packet = @client.recv(4096)
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


th = Thread.new do
  counter = 0
  loop do
    packet = @receiver.recv(256)
    begin
      OSC::Packet.decode(packet).each do |time, message|
#        puts "received: #{message.address}, #{message.to_a}" if message.to_a.at(0) == 17
        counter += 1
      end
    rescue EOFError
      puts "EOFError: packet = #{packet}"
      puts "counter: #{counter}"
      exit
    end    
  end
end

@xs << OSC::Message.new('/query', nil)
@xs << OSC::Message.new('/reset', nil)
@xs << OSC::Message.new('/polling', 'i', 1)
send_commands

sleep(10)

@xs << OSC::Message.new('/polling', 'i', 0)
@xs << OSC::Message.new('/quit', nil)
send_commands

th.join
