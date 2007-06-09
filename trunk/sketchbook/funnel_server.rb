#!/usr/bin/env ruby

require 'socket'
require 'osc'
require 'timeout'
require "gainer_io"

class FunnelServer

  def initialize(port)
    @server = TCPServer.open('localhost', port)
    puts "server: #{@server.addr.at(2)}, #{@server.addr.at(1)}"
    @notifier = TCPServer.open('localhost', port + 1)
    puts "notifier: #{@notifier.addr.at(2)}, #{@notifier.addr.at(1)}"

    @queue = Queue.new
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
      @ain = value
      @queue.push(value)
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
    Thread.start(@server.accept) do |client|
      puts "server: connected: #{client}"

      callbacks = []

      add_method(callbacks, QUIT_SERVER) do |message|
        puts "quit requested"
        @gio.endAnalogInput
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

      puts "server: disconnected: #{client}"
      client.close
    end
  end
end

def notify_service
  socks = [@notifier]

  Thread.new do
    loop do
      ain = @queue.pop
      for s in socks
        if s != @notifier then
          message = OSC::Message.new('/in', 'i', 0, ain.at(0), ain.at(1), ain.at(2), ain.at(3))
          s.send(message.encode, 0)
          #          puts "sent to #{s}"
        end
      end
    end
  end

  Thread.new do
    loop do
      nsock = select(socks)
      next if nsock == nil
      for s in nsock[0]
        if s == @notifier
          client = s.accept
          socks.push(client)
          puts "notifier: connected: #{client}"
        elsif s.eof?
          puts "notifier: disconnected: #{client}"
          s.close
          socks.delete(s)
        end
      end
    end
  end
end

def run
  begin
    notify_service
  rescue
    Thread.main.raise $!
  end

  begin
    client_watcher
  rescue
    Thread.main.raise $!
  end
end

end

# instantiate the FunnelServer and set to run
server = FunnelServer.new(5000)
server.run
