#!/usr/bin/env ruby
require "socket"
class TastyNoodles
  def initialize
    # Right now, host is hard set. This should be something that is read from a config file
    @host = "localhost"
    @hardcoded_response = 'HTTP/1.1 200 OK\r\n'+
    'Date: Tue, 26 Aug 2014 22:38:34 GMT\r\n'+
    'Server: Tastynoodles/0.01 (OSX)\r\n'+
    'Last-Modified: Tue, 26 Aug 2014 23:11:55 GMT\r\n'+
    'ETag: "3f80f-1b6-3e1cb03b"\r\n'+ # What is an etag?
    'Content-Type: text/html; charset=UTF-8\r\n'+
    'Content-Length: 60\r\n'+
    'Accept-Ranges: bytes\r\n'+
    'Connection: close'
  end
  def log(message)
    File.open("./status", "a") { |f| f.write(message) }
  end
  def test
    #Process.daemon
    #puts Process.pid
    #puts Process.getpgrp
    return RUBY_VERSION
  end
  def work
    server = TCPServer.new "localhost", 2000 #<-- bind to port 2000
    loop do 
      Thread.start(server.accept) do |client|
        message = client.gets.chomp.split(" ")
        #interact_by_telnet client
        type = message[0]
        case type
        when "GET"
          #response = @hardcoded_response + '\r\n\r\n' + do_get(message)
          #client.print do_get(message) #<-- this works, but it has no header???
          response = do_get(message)
          client.print "HTTP/1.1 200 OK\r\n" +
                        "Content-Type: text/html\r\n" +
                        "Content-Length: #{response.bytesize}\r\n" +
                        "Connection: close\r\n\r\n" +
                        response
          log "what"
        else
          # not a valid message type. What to do here?
          log "not a valid message type"
        end
        client.close
      end
    end
  end
  def do_get(message)
    # if this is valid, then proceed
    # for the line below, is Host optional in HTTP???
    #if message[2] == "HTTP/1.1" && message[3] == "Host:"
    if message[2] == "HTTP/1.1"
      url = message[1]
      url = url[1, url.length] if url.start_with? "/" # strip leading /
      return File.read(url)
    else
      log message
      return "Throw an error from do_get"
    end
  end
  def interact_by_telnet(client)
      client.puts "Hello World"
      message = client.gets.chomp
      client.puts "You just entered #{message}. Do a tasty status to see your message."
      File.open("./status", "w") { |f| f.write("#{message}\n") }
  end
end

def write_pid
  begin
    File.open("./PID", "w") { |f| f.write "#{Process.pid}" }
    return true
  rescue Exception => e
    my_puts "write_pid failed, error message is: #{e.message}"
    return false
  end
end
def read_pid
  pid = -1
  begin
    pid = File.read("./PID")
  rescue Exception => e
    my_puts "read_pid failed, error message is: #{e.message}"
  end
  return pid
end

def my_puts(message)
  STDOUT.reopen $orig_stdout
  puts message
  STDOUT.reopen "/dev/null", "a"
end

def start
  Process.daemon(true) # <-- true means stay in the current directory
  # Note that you must write the pid to file AFTER creating the daemon, or else you won't
  # have the daemon's pid.
  if write_pid
    File.open("./status", "w") { |f| f.write "So tasty.\n" }
    tasty = TastyNoodles.new
    tasty.work
  else
    my_puts "TastyNoodles daemon might not be operating correctly. Please kill it with a kill -9 pid"
  end

end 
def stop
  Process.kill("SIGTERM", read_pid.to_i)
  File.open("./status", "w") { |f| f.write "Not tasty.\n" }
end
def status
  puts "#{File.read("./status")}"
end

case ARGV[0]
when "start"
  start
when "stop"
  stop
when "status"
  status
when "who"
  puts "#{`ps aux | grep tasty`}"
when "restart"
  stop
  start
when "test"
  puts `ruby testtastynoodles.rb`
else
  puts "Command not recognized. Not tasty."
end
