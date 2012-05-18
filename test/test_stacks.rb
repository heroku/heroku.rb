require File.expand_path("#{File.dirname(__FILE__)}/test_helper")

class TestStacks < MiniTest::Unit::TestCase

  def test_get_stack
    with_app do |app_data|
      response = heroku.get_stack(app_data['name'])

      assert_equal(200, response.status)
    end
  end

  def test_get_stack_app_not_found
    assert_raises(Heroku::API::Errors::NotFound) do
      heroku.get_stack(random_name)
    end
  end

  def test_put_stack
    with_app do |app_data|
      response = heroku.put_stack(app_data['name'], 'bamboo-ree-1.8.7')

      assert_equal(200, response.status)
    end
  end

  def test_put_stack_app_not_found
    assert_raises(Heroku::API::Errors::NotFound) do
      heroku.put_stack(random_name, 'bamboo-ree-1.8.7')
    end
  end

  def test_put_stack_stack_not_found
    with_app do |app_data|
      assert_raises(Heroku::API::Errors::NotFound) do
        heroku.put_stack(app_data['name'], random_name)
      end
    end
  end

  def test_put_stack_cedar
    with_app do |app_data|
      assert_raises(Heroku::API::Errors::RequestFailed) do
        heroku.put_stack(app_data['name'], 'cedar')
      end
    end
  end

end
