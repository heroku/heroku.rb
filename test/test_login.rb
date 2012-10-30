require File.expand_path("#{File.dirname(__FILE__)}/test_helper")

class TestLogin < MiniTest::Unit::TestCase

  def test_post_login
    # FIXME: user/pass will only work in mock for now, maybe use ENV
    response = heroku.post_login('email@example.com', 'fake_password')

    assert_equal(200, response.status)
  end

  def test_post_login_implied
    # FIXME: user/pass will only work in mock for now, maybe use ENV
    _heroku_ = Heroku::API.new(:mock => true, :username => 'email@example.com', :password => 'fake_password')
    response = _heroku_.get_apps

    assert_equal(200, response.status)
  end

end
