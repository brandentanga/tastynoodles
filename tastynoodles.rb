#!/usr/bin/env ruby

# Author: Branden Tanga
# Email: branden.tanga@gmail.com
require "socket"
#require "cgi"

# Tasty Noodles itself
#
class TastyNoodles
  MAX_FOR_RANDOMIZER = 1000000000000000000 # <-- this is close to the max size of Fixnum
  def initialize
    #@cgi = CGI.new("html4")
    @sessions = {}
    # For sessions, houskeeping key=value pairs are Domain, Path, Max-Age, Secure, and Expires
    # For sessions, Set-Cookie: name2=value2; Expires=Wed, 09 Jun 2021 10:18:14 GMT becomes
    # { :tastynoodles_983709713299503548 =>  }
    # @randomizer = Random.new(Time.now.to_i) <-- only needed if Tastynoodles ever needs
    # to set it's own cookies.
    
    # Right now, host is hard set. This should be something that is read from a config file
    @host = "localhost"
    @http_version = "HTTP/1.1"
    @known_content_types = ["html", "javascript", "text", "jpg", "jpeg", "png", "gif"]
    @cookies = ""
  end
  
  # Custom logger, appends to the file 'status' in the tastynoodles directory.
  # When the server exits, this file is overwritten.
  #
  def log(message)
    File.open("./status", "a") { |f| f.write(message + "\n") }
  end
  def test
    #Process.daemon
    #puts Process.pid
    #puts Process.getpgrp
    return RUBY_VERSION
  end
  
  # The main method which loops indefinitely while tastynoodles is running.
  #
  def work
    server = TCPServer.new "localhost", 2000 #<-- bind to port 2000
    loop do 
      Thread.start(server.accept) do |client|
        temp = client.gets("\r\n\r\n")
        log "incoming request == " + temp
        request = temp.chomp.split("\r\n")
        #request = client.gets.chomp.split(" ") <-- switch back to this
        #interact_by_telnet client
        type = request[0].split(" ")[0]
        @cookies = request.select{|x| x.include?("Cookie")}[0]
        log "type == #{type}"
        case type
        when "HEAD"
          response = do_head(request)
          client.print response
          log "HEAD #{request[1]}"
        when "GET"
          response = do_get(request)
          client.print response
          log "GET #{request[0]}"
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
  
  # This method handles a head request. It is basically a pass through to do_get,
  # since a head request is identical to a get, except that there is no content
  # in a response to a head request. 
  #
  def do_head(request)
    do_get(request, :head)
  end
  
  # This method handles a get request.
  #
  def do_get(request, get_or_head = :get)
    # if this is valid, then proceed
    # Host is mandatory, and either Content-Length or Transfer-Encoding.
    message = nil
    request_header = request[0].split(" ")
    log "request_header == #{request_header}"
    if request_header[2] == @http_version
      log "do_get request == #{request.to_s}"
      url = request_header[1]
      url = url[1, url.length] if url.start_with? "/" # strip leading /
      begin
        message = File.read(url) # if not found, read returns nil
        response_header = "#{@http_version} 200 OK\r\n" +
                  generate_common_response_header_fields(url, message) +
                  # Domain, Path, Max-Age, Secure, and Expires
                  #"Set-Cookie: tastynoodles=true;\r\n" +
                  #"Set-Cookie: visit_count=1;\r\n" + 
                  "#{@cookies}\r\n" +
                  "Connection: close\r\n\r\n"
        log "response == " + response_header + message
        #return header + message
        return (get_or_head == :get ? response_header + message : response_header)
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
  #
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
  
  # This method is responsible for generating markup for all http error messages to be
  # sent back to the client.
  #
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
  
  # This method simplifies the drudgery of creating markup for error pages that are 
  # almost always nearly identical.
  #
  def generate_simple_html_page_for_error(info_string)
    return "#{@http_version} #{info_string}. No tasty noodles for you.\r\n" + 
            "Connection: close\r\n\r\n" + 
            generate_simple_html_page("#{info_string}. No tasty noodles for you." +
            "<br /><img src=http://i.imgur.com/ODaIazU.gif>")
  end
  
  # This method generates html, head, and body tags for use in other methods.
  #
  def generate_simple_html_page(content_of_body)
    return "<html><head></head><body>" + content_of_body + "</body></html>"
  end
  
  # This method accepts a request as an array of parameters,
  # and returns an array of cookies as a hash. A hash being unordered is acceptable,
  # because per the http spec, cookies are supposed to be unordered.
  def get_request_cookies(request)
    
  end
  
  # This method generates the session cookie 
  #
  def generate_session_cookie
    return "tastynoodles=session_id:#{generate_random_fixnum}"
  end
  
  # This method generates a random fixnum that is near the maximum size of
  # fixnum. This is intended to be used to help keep track of independent
  # sessions with minimal chance of collisions.
  #
  def generate_random_fixnum
    return @randomizer.rand(MAX_FOR_RANDOMIZER)
  end
  
  # A testing method which allows you to send and recieve simple messages
  # through telnet
  #
  def interact_by_telnet(client)
      client.puts "Hello World"
      request = client.gets.chomp
      client.puts "You just entered #{request}. Do a tasty status to see your request."
      File.open("./status", "w") { |f| f.write("#{request}\n") }
  end
  
end # end tastynoodles class


# This function writes the PID of the current tastynoodles process to a file
# called PID in the tastynoodles directory. Tastynoodles uses this to know
# which process to shutdown when tasty stop is executed.
#
def write_pid
  begin
    File.open("./PID", "w") { |f| f.write "#{Process.pid}" }
    return true
  rescue Exception => e
    my_puts "write_pid failed, error message is: #{e.message}"
    return false
  end
end

# This function reads the PID file to get the process id of the current
# tastynoodles daemon.
#
def read_pid
  pid = -1
  begin
    pid = File.read("./PID")
  rescue Exception => e
    my_puts "read_pid failed, error message is: #{e.message}"
  end
  return pid
end

# This function temporarily redirects STDOUT to a terminal session, then returns
# it to /dev/null
#
def my_puts(message)
  STDOUT.reopen $orig_stdout
  puts message
  STDOUT.reopen "/dev/null", "a"
end

# This function starts the tastynoodles daemon.
#
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

# This function stops the tastynoodles daemon
#
def stop
  Process.kill("SIGTERM", read_pid.to_i)
  File.open("./status", "w") { |f| f.write "Not tasty.\n" }
end

# This function reads the status file and outputs it to STDOUT
#
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
