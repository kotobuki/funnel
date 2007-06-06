#!/usr/bin/env ruby

require 'socket'
require 'osc'
require 'timeout'

port = 7123

class SimpleTCPServer
  def initialize(port)
    @so = TCPServer.new('localhost', port)
    @cb = []
    @qu = Queue.new
    @clients = []
  end

def wait_for_connection
  loop do
#    puts "waiting for connection..."
    begin
      Timeout::timeout(1) do
        client = @so.accept
        puts "connected: host = #{client.peeraddr.at(2)}, port = #{client.peeraddr.at(1)}"
        @clients << client
        p @clients
      end
    rescue Timeout::Error
      sleep(1)
    end
  end
end

def send_notify(message, sender)
  puts "send_notify()"
end

def send_reply(message, sender)
  client = @clients.at(sender)
  client.send(message.encode, 0)
#  @clients.at(sender).send(message.encode, 0) unless @clients.at(sender) != nil  # WHY???
end

def add_method(pat, obj=nil, &proc)
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
      @cb << [re, (obj || proc)]
    end

def handle_message(mesg, sender)
  @cb.each do |re, obj|
    if re.nil? || re =~ mesg.address
      obj.send(if Proc === obj then :call else :accept end, mesg, sender)
    end
  end
end

def dispatcher
  loop do
    msg, sender = @qu.pop
    time, mesg = msg
    now = Time.now.to_f + 2208988800
    diff = if time.nil?
      then 0 else time - now end
      if diff <= 0
        handle_message(mesg, sender)
      else
        Thread.fork do
          sleep(diff)
          handle_message(mesg)
          Thread.exit
        end
      end
    end
  end

def detector
  loop do
    id = 0
    @clients.each do |client|
      packet = client.recv(16384)
      begin
        OSC::Packet.decode(packet).each{|x| @qu.push([x, id])}
      rescue EOFError
      end
      id += 1
    end
  end
end

private :handle_message, :dispatcher, :detector

def run
  Thread.new do
    begin
      dispatcher
    rescue
      Thread.main.raise $!
    end
  end

  Thread.new do
    begin
      wait_for_connection
    rescue
      Thread.main.raise $!
    end
  end

  begin
    detector
  rescue
    Thread.main.raise $!
  end
end

end


th = Thread.new do
  server = SimpleTCPServer.new(port)

  server.add_method('/funnel/quit') do |message, sender|
    puts "quit requested"
    reply = OSC::Message.new('/funnel/quit', 's', 'OK')
    server.send_reply(reply, sender)
    sleep(0.5)
    exit
  end

#  server.add_method('/funnel/*') do |message, sender|
#    p [message.address, message.to_a]
#    p sender
#    exit if message.address =~ /\/quit\z/
#  end

  server.run
end

th.join
