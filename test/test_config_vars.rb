require File.expand_path("#{File.dirname(__FILE__)}/test_helper")

class TestConfigVars < MiniTest::Unit::TestCase

  def test_delete_config_vars
    with_app('stack' => 'cedar') do |app_data|
      heroku.put_config_vars(app_data['name'], {'KEY' => 'value'})

      response = heroku.delete_config_vars(app_data['name'], 'KEY')

      assert_equal(200, response.status)
      assert_equal({}, response.body)
    end
  end

  def test_delete_config_vars_app_not_found
    assert_raises(Heroku::API::Errors::NotFound) do
      heroku.delete_config_vars(random_name, 'key')
    end
  end

  def test_get_config_vars
    with_app('stack' => 'cedar') do |app_data|
      response = heroku.get_config_vars(app_data['name'])

      assert_equal(200, response.status)
      assert_equal({}, response.body)
    end
  end

  def test_get_config_vars_app_not_found
    assert_raises(Heroku::API::Errors::NotFound) do
      heroku.get_config_vars(random_name)
    end
  end

  def test_put_config_vars
    with_app('stack' => 'cedar') do |app_data|
      response = heroku.put_config_vars(app_data['name'], {'KEY' => 'value'})

      assert_equal(200, response.status)
      assert_equal({'KEY' => 'value'}, response.body)

      heroku.delete_config_vars(app_data['name'], 'KEY')
    end
  end

  def test_put_config_vars_app_not_found
    assert_raises(Heroku::API::Errors::NotFound) do
      heroku.put_config_vars(random_name, {'KEY' => 'value'})
    end
  end

end
