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
    server = TCPServer.new 2000 #<-- bind to port 2000
    while true
      client = server.accept
      client.puts "Hello World"
      client.close
      sleep 2
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
else
  "command not recognized"
end
