require File.expand_path("#{File.dirname(__FILE__)}/test_helper")

class TestApps < Minitest::Test

  def test_put_buildpacks
    with_app do |app_data|
      response = heroku.put_buildpacks(app_data['name'], ["heroku/ruby"])

      assert_equal(200, response.status)
      assert_equal("", response.body)
    end
  end
end
