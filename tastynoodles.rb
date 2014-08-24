#!/usr/bin/env ruby
require "socket"
class TastyNoodles
  def test
    #Process.daemon
    puts Process.pid
    puts Process.getpgrp
    puts RUBY_VERSION
  end
  def work
    server = TCPServer.new "localhost", 2000 #<-- bind to port 2000
    loop do 
      Thread.start(server.accept) do |client|
        client.puts "Hello World"
        message = client.gets.chomp
        client.puts "You just entered #{message}. Do a tasty status to see your message."
        File.open("./status", "w") { |f| f.write("#{message}\n") }
        client.close
      end
    end
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
  `telnet localhost 2000`
else
  puts "Command not recognized. Not tasty."
end
