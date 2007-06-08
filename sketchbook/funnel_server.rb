#!/usr/bin/env ruby

require 'socket'
require 'osc'
require 'timeout'
require "gainer_io"

port = 7123

class FunnelServer

  def initialize(port)
    @server = TCPServer.new('localhost', port)
    #    @callbacks = []
    @addedClients = Queue.new
    @removedClients = Queue.new
    @clients = []
    @ain = [0, 0, 0, 0]

    devices = []

    Dir.foreach("/dev") do | deviceName |
      devices.push(deviceName) if (deviceName.index("cu.usbserial") == 0)
    end

    if (devices.size < 1) then
      raise "Can't find any I/O modules..."
    end

    @gio = GainerIO.new('/dev/' + devices.at(0), 38400)
    @gio.onEvent = method(:onEvent)
    reboot_io_module
  end

  def onEvent(type, value)
    if (type == GainerIO::AIN_EVENT) then
#      info = OSC::Message.new('/in', 'i', 0, value.at(0), value.at(1), value.at(2), value.at(3))
#      send_notify(info)
      @ain = value
    elsif (type == GainerIO::SW_EVENT) then
#      info = OSC::Message.new('/in', 'i', 16, value)
#      send_notify(info)
    else
      puts "#{type}: #{value}"
    end
  end
  
  def reboot_io_module
    puts @gio.reboot
    puts @gio.getVersion
    puts @gio.setConfiguration(1)
  end

def send_notify(message)
  return
  @clients.each do |client|
    result = client.send(message.encode, 0)
  end
end

def add_method(callbacks, pat, obj=nil, &proc)
  case pat
  when NIL; re = pat
  when Regexp; re = pat
  when String
    pat = pat.dup
    pat.gsub!(/[.^(|)]/, '\\1')
    pat.gsub!(/\?/, '[^/]')
    pat.gsub!(/\*/, '[^/]*')
    pat.gsub!(/\[!/, '[^')
    pat.gsub!(/\{/, '(')
    pat.gsub!(/,/, '|')
    pat.gsub!(/\}/, ')')
    pat.gsub!(/\A/, '\A')
    pat.gsub!(/\z/, '\z')
    re = Regexp.new(pat)
  else
    raise ArgumentError, 'invalid pattern'
  end

  unless ( obj && !proc) ||
    (!obj &&  proc)
    raise ArgumentError, 'wrong number of arguments'
  end
  callbacks << [re, (obj || proc)]
end

def handle_message(callbacks, message)
  callbacks.each do |re, obj|
    if re.nil? || re =~ message.address
      obj.send(if Proc === obj then :call else :accept end, message)
    end
  end
end

QUIT_SERVER = '/quit'
RESET       = '/reset'
POLLING     = '/polling'
QUERY       = '/query'
SET_OUTPUTS = '/out'
GET_INPUTS  = '/in'

NO_ERROR    = 0
ERROR       = 1

def client_watcher
  loop do
    puts "waiting for connection..."

    Thread.start(@server.accept) do |client|
      puts "connected: #{client}"

      callbacks = []

      add_method(callbacks, QUIT_SERVER) do |message|
        puts "quit requested"
        reply = OSC::Message.new(QUIT_SERVER, 'i', NO_ERROR)
        client.send(reply.encode, 0)
        exit
      end

      add_method(callbacks, RESET) do |message|
        puts "reset requested"
        reboot_io_module
        reply = OSC::Message.new(RESET, 'i', NO_ERROR)
        client.send(reply.encode, 0)
      end

      add_method(callbacks, POLLING) do |message|
        puts "polling"
        if message.to_a.at(0) == 1 then
          puts "begin polling requested"
          @gio.beginAnalogInput
          @gio.startPolling
        elsif message.to_a.at(0) == 0 then
          puts "end polling requested"
          @gio.finishPolling
          @gio.endAnalogInput
        else
          puts "invalid value: #{message.to_a.at(0)}"
          reply = OSC::Message.new(POLLING, 'i', ERROR)
          client.send(reply.encode, 0)
          return
        end
        reply = OSC::Message.new(POLLING, 'i', NO_ERROR)
        client.send(reply.encode, 0)
      end

      add_method(callbacks, QUERY) do |message|
      end

      add_method(callbacks, SET_OUTPUTS) do |message|
        @gio.setOutputs(message.to_a)
        reply = OSC::Message.new(SET_OUTPUTS, 'i', NO_ERROR)
        client.send(reply.encode, 0)
      end

      add_method(callbacks, GET_INPUTS) do |message|
        reply = OSC::Message.new(GET_INPUTS, 'i', 0, @ain.at(0), @ain.at(1), @ain.at(2), @ain.at(3))
        client.send(reply.encode, 0)
      end

      while true
        packet = client.recv(16384)   # blocking read
        break if packet == ""         # "" means EOF for TCP connection

        begin
          OSC::Packet.decode(packet).each do |time, message|
            handle_message(callbacks, message)
          end
        rescue EOFError
        end
      end

      puts "disconnected: #{client}"
      client.close
    end
  end
end

def run
  begin
    client_watcher
  rescue
    Thread.main.raise $!
  end
end

end


th = Thread.new do
  server = FunnelServer.new(port)
  server.run
end

th.join
