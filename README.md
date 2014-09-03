## About Tastynoodles
Have a simple webserver implemented in Ruby, or eat some tasty noodles? Why not both?

## No seriously, what's the deal with Tastynoodles?
For my own edification, I wanted to write my own webserver. Tastynoodles is just a whimsical name I chose because I was hungry when I started this project.

## So it's a production quality webserver?
**Absolutely Not**. Right now, I support the bare minimum of what is required to be a webserver under HTTP 1.1, which is surprisingly not much, just the ability to respond to HEAD and GET.

## So what can Tastynoodles do right now?
* Run as a daemon on OSX (probably works on Linux too)
* Has start/stop/status commands, available from the command line 
* Can accept HEAD and GET requests, can respond with 200 OK and send requested files
* Can work with common text or image files: text/text, text/javascript, text/html, image/jpg, image/png, image/gif
* Can send the following errors: 404, 405, 501, 505

## What will Tastynoodles do in the future?
### Near future:
* Support cookies (partial implementation done, not merged with master branch yet)
* Support all the HTTP request types, GET, HEAD, POST, PUT, DELETE, OPTIONS, TRACE
* Support all common HTTP error types

### Medium term:
* Simple URL rewriting
* Refactoring because I'm sure the code will be ugly by then

### Long term:
* CGI support for Ruby, possibly look at being Rack compliant
* SSL support

## Will Tastynoodles ever do any of the following?
* Reverse proxy
* CGI support for other languages
* Advanced URL rewriting
* Load balancing
* Caching
* Basically anything advanced that Apache or Nginx does

^^ For all of the above, **maybe**. Many people much smarter than me put lots of effort into all of the various production quality webservers out there. My intent with Tastynoodles is to learn, and perhaps understand more of what goes on under the hood of a webserver, which has already informed and solidified my understanding of the underlying layers of the web stack. For example, many budding RoR devs know that you install Phusion Passenger on Apache or Nginx, and you can run Rails. But what's going on under the hood? Passenger makes Apache/Nginx's CGI Rack compliant. Rack handles common tasks between all servers and frameworks, like passing session cookies around, or handling incoming requests and outbound responses between the webserver and web framework. So if you're writing a webserver, and you want to be able to run Rails, Sinatra, etc., you make it Rack compliant. If you're writing a web framework, and you want to run it on Apache, Nginx, Thin, etc., you make it Rack compliant. Tada! Learning! \o/