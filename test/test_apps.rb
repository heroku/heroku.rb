require "#{File.dirname(__FILE__)}/test_helper"

class TestApps < MiniTest::Unit::TestCase
  def setup
    @heroku = Heroku.new(:api_key => 'API_KEY', :mock => true)
  end

  def test_get_apps
    response = @heroku.get_apps
    assert_equal 200, response.status
    assert_equal [], response.body
  end

end
