require File.expand_path("#{File.dirname(__FILE__)}/test_helper")

class TestUser < Minitest::Test

  def test_get_user
    response = heroku.get_user
    data = File.read("#{File.dirname(__FILE__)}/../lib/heroku/api/mock/cache/get_user.json")

    assert_equal(200, response.status)
    assert_equal(MultiJson.load(data), response.body)
  end

end
