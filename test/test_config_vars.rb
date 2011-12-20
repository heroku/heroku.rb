require "#{File.dirname(__FILE__)}/test_helper"

class TestConfigVars < MiniTest::Unit::TestCase

  def setup
    @heroku = Heroku.new(:api_key => 'API_KEY', :mock => true)
  end

  def test_delete_app_config_var
    with_app do |app|
      @heroku.put_app_config_vars(app['name'], {'KEY' => 'value'})

      response = @heroku.delete_app_config_var(app['name'], 'KEY')

      assert_equal(200, response.status)
      assert_equal({}, response.body)
    end
  end

  def test_delete_app_config_var_app_not_found
    assert_raises(Excon::Errors::NotFound) do
      @heroku.delete_app_config_var(random_app_name, 'key')
    end
  end

  def test_get_app_config_vars
    with_app do |app|
      response = @heroku.get_app_config_vars(app['name'])

      assert_equal(200, response.status)
      assert_equal({}, response.body)
    end
  end

  def test_get_app_config_vars_app_not_found
    assert_raises(Excon::Errors::NotFound) do
      @heroku.get_app_config_vars(random_app_name)
    end
  end

  def test_put_app_config_vars
    with_app do |app|
      response = @heroku.put_app_config_vars(app['name'], {'KEY' => 'value'})

      assert_equal(200, response.status)
      assert_equal({'KEY' => 'value'}, response.body)

      @heroku.delete_app_config_var(app['name'], 'KEY')
    end
  end

  def test_put_app_config_vars_app_not_found
    assert_raises(Excon::Errors::NotFound) do
      @heroku.put_app_config_vars(random_app_name, {'KEY' => 'value'})
    end
  end

end
