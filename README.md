# About Tastynoodles
Have a simple webserver implemented in Ruby, or eat some tasty noodles? Why not both?
# No seriously, what's the deal with Tastynoodles?
For my own edification, I wanted to write my own webserver. Tastynoodles is just a whimsical name I chose because I was hungry when I started this project.
# So it's a production quality webserver?
**Absolutely Not**. Right now, I support the bare minimum of what is required to be a webserver under HTTP 1.1, which is surprisingly not much, just the ability to respond to HEAD and GET.
# So what can Tastynoodles do right now?
Right now, Tastynoodles runs as a daemon on OSX (probably works on Linux too), has start/stop/status commands, can accept HEAD and GET requests, can respond with common text or image files (200 OK), and can send the following errors: 404, 405, 501, 505.