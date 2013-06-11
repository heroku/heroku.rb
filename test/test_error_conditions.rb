require File.expand_path("#{File.dirname(__FILE__)}/test_helper")

class TestErrorConditions < Minitest::Test

  def test_request_without_app_returns_a_sensible_error
    assert_raises(Heroku::API::Errors::NilApp) do
      heroku.delete_domain("", 'example.com')
    end
  end

end
