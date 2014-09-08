#!/usr/bin/env ruby
# A sample cgi file meant to be used with the included index.html
def log(message)
  File.open("../status", "a") { |f| f.write(message + "\n") }
end

log "CGI ME BABY"
