require "minitest/autorun"
load "tastynoodles.rb"

class TestTastyNoodles < Minitest::Unit::TestCase
  def setup
    @tasty = TastyNoodles.new
    #@request = "GET /index.html HTTP/1.1\nHost: www.example.com"
    @request = "GET /index.html HTTP/1.1\nHost: localhost".split(" ")
    #@index = "<html>\n<head></head>\n<body>\nHello World\n</body>\n</html>\n"
    @index = "<html>\n<head></head>\n<body>\nHello World\n</body>\n</html>\n"
    @e501 = "HTTP/1.1 501 Not a valid request type. No tasty noodles for you.\r\n" +
            "Connection: close\r\n\r\n<html><head></head><body>501 Not a valid request type. No tasty noodles for you.<br /><img src=http://i.imgur.com/ODaIazU.gif></body></html>"
    @e405 = "HTTP/1.1 405 Method not allowed. No tasty noodles for you.\r\n" +
            "Connection: close\r\n\r\n<html><head></head><body>405 Method not allowed. No tasty noodles for you.<br /><img src=http://i.imgur.com/ODaIazU.gif></body></html>"
    @e404 = "HTTP/1.1 404 Not found. No tasty noodles for you.\r\n" +
            "Connection: close\r\n\r\n<html><head></head><body>404 Not found. No tasty noodles for you.<br /><img src=http://i.imgur.com/ODaIazU.gif></body></html>"
  end
  def test_test_method
    assert_equal "2.1.1", @tasty.test
  end
  def test_start_and_stop
    `ruby tastynoodles.rb start`
    sleep 1
    assert_equal "So tasty.\n", File.read("./status")
    result = `ruby tastynoodles.rb who`
    assert result.include? "ruby tastynoodles"
    `ruby tastynoodles.rb stop`
    sleep 1
    assert_equal "Not tasty.\n", File.read("./status")
  end
  def test_work
    puts "Skip 1: Not feasible to test the work method in a unit testing capacity"
    skip "Skip 1: Not feasible to test the work method in a unit testing capacity"
    #`ruby tastynoodles.rb start`
  end
  def test_do_get
    # test the header
    result = @tasty.do_get(@request).split("\r\n\r\n")
    first_line = result[0].split(" ")
    assert_equal first_line[0], "HTTP/1.1"
    assert_equal "#{first_line[1]} #{first_line[2]}", "200 OK"
    
    #test the message
    assert_equal @index, result[1]
  end
  def test_generate_http_error_message
    assert_equal @e501, @tasty.generate_http_error_message(:e501)
    assert_equal @e405, @tasty.generate_http_error_message(:e405)
    assert_equal @e404, @tasty.generate_http_error_message(:e404)
  end
  def test_generate_simple_html_page
    #skip "for now"
    assert_equal "<html><head></head><body>hello world</body></html>", 
                  @tasty.generate_simple_html_page("hello world")
  end
  def test_generate_common_response_header_fields
    header = @tasty.generate_common_response_header_fields("http://localhost:2000/index.html", 
                          "<html><head></head><body>hello world</body></html>").split("\r\n")
    # We don't test the date, because it will differ by seconds from when the Date field is 
    # generated in the generate_common_response_header_fields function call, and when we might 
    # call Time.now in testing.
    assert_equal header[1], "Server: TastyNoodles/0.1"
    assert_equal header[2], "Content-Type: html"
    assert_equal header[3], "Content-Length: 50"
  end
end