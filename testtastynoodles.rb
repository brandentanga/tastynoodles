require "minitest/autorun"
load "tastynoodles.rb"

class TestTastyNoodles < Minitest::Unit::TestCase
  def setup
    @tasty = TastyNoodles.new
    #@request = "GET /index.html HTTP/1.1\nHost: www.example.com"
    @request = "GET /index.html HTTP/1.1\nHost: localhost".split(" ")
    @index = "<html>\n<head></head>\n<body>\nHello World\n</body>\n</html>\n"
    @e501 = "HTTP/1.1 501 Not a valid request type. No tasty noodles for you.\r\n" +
            "Connection: close\r\n\r\n<html><head></head><body>501 not a valid request type. No tasty noodles for you. <br /><img src=http://i.imgur.com/ODaIazU.gif></body></html>"
    @e405 = "HTTP/1.1 405 method not allowed. No tasty noodles for you. \r\n" +
            "Connection: close\r\n\r\n<html><head></head><body>405 method not allowed. No tasty noodles for you. <br /><img src=http://i.imgur.com/ODaIazU.gif></body></html>"
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
    #puts @index
    assert_equal @index, @tasty.do_get(@request)
  end
  def test_generate_http_error_message
    assert_equal @e501, @tasty.generate_http_error_message(:e501)
    assert_equal @e405, @tasty.generate_http_error_message(:e405)
  end
  def test_generate_simple_html_page
    skip "for now"
  end
end