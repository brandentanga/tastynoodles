require "minitest/autorun"
load "tastynoodles.rb"

class TestTastyNoodles < Minitest::Unit::TestCase
  def setup
    @tasty = TastyNoodles.new
    #@request = "GET /index.html HTTP/1.1\nHost: www.example.com"
    @request = "GET /index.html HTTP/1.1\nHost: localhost".split(" ")
    @index = "<html>\n<head></head>\n<body>\nHello World\n</body>\n</html>\n"
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
    skip "Not feasible to test the work method in a unit testing capacity"
    #`ruby tastynoodles.rb start`
  end
  def test_do_get
    puts @index
    assert_equal @index, @tasty.do_get(@request)
  end
end