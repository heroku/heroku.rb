require File.expand_path("#{File.dirname(__FILE__)}/test_helper")

class TestLogin < MiniTest::Unit::TestCase

  def test_post_login
    # FIXME: user/pass will only work in mock for now, maybe use ENV
    response = heroku.post_login('email@example.com', 'fake_password')

    assert_equal(200, response.status)
  end

end
