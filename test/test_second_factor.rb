require File.expand_path("#{File.dirname(__FILE__)}/test_helper")

class TestSecondFactor < Minitest::Test

  def test_second_factor_cleared
    # this test just checks to see if the token is cleared
    _heroku_ = heroku
    _heroku_.second_factor = 'ccccccdhtnjniifelbvgblltgeigleglenfbvnkgvtlb'
    _heroku_.get_user

    assert_nil(_heroku_.second_factor)
  end
end
