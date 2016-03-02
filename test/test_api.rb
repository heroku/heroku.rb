require File.expand_path("#{File.dirname(__FILE__)}/test_helper")

class TestApi < Minitest::Test

  def test_json_parsing_failure_for_application_json
    Excon.stub(:expects => 200, :method => :get, :path => "/foobar") do |params|
      {
        :body   => "string",
        :status => 200,
        :headers => {'Content-Type' => 'application/json'}
      }
    end

    begin
      heroku.request(:expects => 200, :method => :get, :path => "/foobar")
      fail("Expected MultiJson::ParseError")
    rescue MultiJson::ParseError
      # should raise parse error
    end
  end

  def test_json_parsing_failure_for_text_plain
    Excon.stub(:expects => 200, :method => :get, :path => "/foobar") do |params|
      {
        :body   => "string",
        :status => 200,
        :headers => {'Content-Type' => 'text/plain'}
      }
    end

    response = heroku.request(:expects => 200, :method => :get, :path => "/foobar")

    assert_equal(200, response.status)
    assert_equal("string", response.body)
  end

end
