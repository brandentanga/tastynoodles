#!/usr/bin/env ruby
require "socket"

class TastyNoodles
  def initialize
    # Right now, host is hard set. This should be something that is read from a config file
    @host = "localhost"
    @http_version = "HTTP/1.1"
    @known_content_types = ["html", "javascript", "text", "jpg", "jpeg", "png", "gif"]
    @hardcoded_response = "#{@http_version} 200 OK\r\n" +
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
    File.open("./status", "a") { |f| f.write(message + "\n") }
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
        request = client.gets.chomp.split(" ")
        #interact_by_telnet client
        type = request[0]
        case type
        when "HEAD"
          #log "Error 405, method not allowed"
          #client.print generate_http_error_message(:e405)
          response = do_head(request)
          client.print response
          log "HEAD #{request[1]}"
        when "GET"
          #response = @hardcoded_response + '\r\n\r\n' + do_get(request)
          #client.print do_get(request) #<-- this works, but it has no header???
          response = do_get(request)
          client.print response
          log "GET #{request[1]}"
        when "OPTIONS"
          log "Error 405, method not allowed"
          client.print generate_http_error_message(:e405)
        when "TRACE"
          log "Error 405, method not allowed"
          client.print generate_http_error_message(:e405)
        when "POST"
          log "Error 405, method not allowed"
          client.print generate_http_error_message(:e405)
        when "PUT"
          log "Error 405, method not allowed"
          client.print generate_http_error_message(:e405)
        when "DELETE"
          log "Error 405, method not allowed"
          client.print generate_http_error_message(:e405)
        when "TRACE"
          log "Error 405, method not allowed"
          client.print generate_http_error_message(:e405)
        when "CONNECT"
          log "Error 405, method not allowed"
          client.print generate_http_error_message(:e405)
        else
          # not a valid request type. What to do here?
          # Error 501 not implemented if it is an unknown or unimplemented request type
          log "Error 501, not a valid request type"
          # Note that ruby symbols cannot start with a digit, thus the 'e'
          client.print generate_http_error_message(:e501)
        end
        client.close
      end
    end
  end
  def do_head(request)
    do_get(request, :head)
  end
  def do_get(request, get_or_head = :get)
    # if this is valid, then proceed
    # Host is mandatory, and either Content-Length or Transfer-Encoding.
    message = nil
    if request[2] == @http_version
      log "do_get request == #{request.to_s}"
      url = request[1]
      url = url[1, url.length] if url.start_with? "/" # strip leading /
      begin
        message = File.read(url) # if not found, read returns nil
        header = "#{@http_version} 200 OK\r\n" +
                  generate_common_response_header_fields(url, message) +
                  "Connection: close\r\n\r\n"
        log header + message
        #return header + message
        return (get_or_head == :get ? header + message : header)
      rescue Errno::ENOENT => e # File not found
        log e.message
        return generate_http_error_message(:e404)
      end
    else # error 505 http version not supported.
      #log request
      log "in else"
      return generate_http_error_message(:e505)
    end
  end
  
  # Generate the header fields used across all response headers
  def generate_common_response_header_fields(url, message)
    content_type = url[url.rindex(".") + 1, url.length] if url.include?(".")
    content_type ||= "root" # if there's no .html for example url rewrite engine will solve this
    length_or_encoding = :content_length
    #insert_me = (length_or_encoding == :content_length ? "Content-Length: #{message.bytesize}\r\n\r\n")
    return "Date: #{Time.now.utc.strftime("%a, %d %b %Y %H:%M:%S GMT")}\r\n" + 
            "Server: TastyNoodles/0.1\r\n" +
            "Content-Type: #{@known_content_types.find_index(content_type) != nil ? content_type : "unknown" }\r\n" + 
            (length_or_encoding == :content_length ? "Content-Length: #{message.bytesize}" : "Transfer-Encoding: #{message.to_s}") +
            "\r\n"
  end
  def generate_http_error_message(type)
    # Note that ruby symbols cannot start with a digit, thus the 'e'
    case type
    when :e404
      return generate_simple_html_page_for_error "404 Not found"
    when :e505
      return generate_simple_html_page_for_error "505 HTTP version not supported"
    when :e405
      return generate_simple_html_page_for_error "405 Method not allowed"
    when :e501
      return generate_simple_html_page_for_error "501 Not a valid request type"
    else
      log "The server is trying to send an unknown http error message to the client. #{type}"
    end
  end
  def generate_simple_html_page_for_error(info_string)
    return "#{@http_version} #{info_string}. No tasty noodles for you.\r\n" + 
            "Connection: close\r\n\r\n" + 
            generate_simple_html_page("#{info_string}. No tasty noodles for you." +
            "<br /><img src=http://i.imgur.com/ODaIazU.gif>")
  end
  def generate_simple_html_page(content_of_body)
    return "<html><head></head><body>" + content_of_body + "</body></html>"
  end
  def interact_by_telnet(client)
      client.puts "Hello World"
      request = client.gets.chomp
      client.puts "You just entered #{request}. Do a tasty status to see your request."
      File.open("./status", "w") { |f| f.write("#{request}\n") }
  end
  
end # end tastynoodles class

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
