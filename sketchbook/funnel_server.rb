#!/usr/bin/env ruby

require 'socket'
require 'osc'
require 'timeout'

port = 7123

class FunnelServer
  def initialize(port)
    @server = TCPServer.new('localhost', port)
#    @callbacks = []
#    @queue = Queue.new
    @clients = []
  end

def send_notify(message)
  puts "send_notify()"
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

def client_watcher
  loop do
    puts "waiting for connection..."
    Thread.start(@server.accept) do |client|
      puts "connected: #{client}"

      callbacks = []

      add_method(callbacks, '/funnel/quit') do |message|
        puts "quit requested"
        reply = OSC::Message.new('/funnel/quit', 's', 'OK')
        client.send(reply.encode, 0)
        exit
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

#private :add_method :handle_message, :client_watcher

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
