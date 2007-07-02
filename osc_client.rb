#!/usr/bin/env ruby

require "socket"
require "yaml"
require 'osc'

# load setting from the setting file
settings = YAML.load_file('settings.yaml')
port = settings["port"]
port = 5432 if port == nil

PORT_AIN = 0
PORT_DIN = 1
PORT_AOUT = 2
PORT_DOUT = 3

@configuration = [
    PORT_AIN,
    PORT_AIN,
    PORT_AIN,
    PORT_AIN,
    PORT_DIN,
    PORT_DIN,
    PORT_DIN,
    PORT_DIN,
    PORT_AOUT,
    PORT_AOUT,
    PORT_AOUT,
    PORT_AOUT,
    PORT_DOUT,
    PORT_DOUT,
    PORT_DOUT,
    PORT_DOUT,
    PORT_DOUT,  # LED
    PORT_DIN,  # Button
  ]

@client = TCPSocket.open('localhost', port)
p @client
@receiver = TCPSocket.open('localhost', port + 1)
p @receiver

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

@xs << OSC::Message.new('/configure', 'i', *@configuration)
@xs << OSC::Message.new('/samplingInterval', 'i', 20)
@xs << OSC::Message.new('/reset', nil)
@xs << OSC::Message.new('/polling', 'i', 1)

10.times do
  @xs << OSC::Message.new('/out', 'if', 16, 1)
  @xs << OSC::Message.new('/out', 'if', 16, 0)
end

send_commands

sleep(5)

@xs << OSC::Message.new('/polling', 'i', 0)
#@xs << OSC::Message.new('/quit', nil)
send_commands

th.join
