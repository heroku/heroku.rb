require "#{File.dirname(__FILE__)}/test_helper"

class TestUser < MiniTest::Unit::TestCase

  def test_get_keys
    response = heroku.get_user

    assert_equal(200, response.status)
  end

end
