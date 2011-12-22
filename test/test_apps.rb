require "#{File.dirname(__FILE__)}/test_helper"

class TestApps < MiniTest::Unit::TestCase

  def test_delete_app
    with_app do |app|
      response = heroku.delete_app(app['name'])
      assert_equal({}, response.body)
      assert_equal(200, response.status)
    end
  end

  def test_delete_app_not_found
    assert_raises(Excon::Errors::NotFound) do
      heroku.delete_app(random_app_name)
    end
  end

  def test_get_apps
    with_app do |app|
      response = heroku.get_apps
      assert_equal(200, response.status)
      assert_equal(app['name'], response.body.first['name'])
    end
  end

  def test_get_apps_empty
    response = heroku.get_apps
    assert_equal(200, response.status)
    assert_equal([], response.body)
  end

  def test_get_app
    with_app do |app|
      response = heroku.get_app(app['name'])
      assert_equal(200, response.status)
      assert_equal(app['name'], response.body['name'])
    end
  end

  def test_get_app_not_found
    assert_raises(Excon::Errors::NotFound) do
      heroku.get_app(random_app_name)
    end
  end

  def test_post_app
    response = heroku.post_app

    assert_equal(202, response.status)

    heroku.delete_app(response.body['name'])
  end

  def test_post_app_with_name
    name = random_app_name
    response = heroku.post_app('name' => name)

    assert_equal(202, response.status)
    assert_equal(name, response.body['name'])

    heroku.delete_app(name)
  end

  def test_post_app_with_duplicate_name
    name = random_app_name
    response = heroku.post_app('name' => name)

    assert_raises(Excon::Errors::UnprocessableEntity) do
      heroku.post_app('name' => name)
    end

    heroku.delete_app(name)
  end

  def test_post_app_with_stack
    response = heroku.post_app('stack' => 'cedar')

    assert_equal(202, response.status)
    assert_equal('cedar', response.body['stack'])

    heroku.delete_app(response.body['name'])
  end

  def test_put_app_not_found
    name = random_app_name
    assert_raises(Excon::Errors::NotFound) do
      heroku.put_app(name, 'name' => random_app_name)
    end
  end

  def test_put_app_with_name
    with_app do |app|
      new_name = random_app_name

      response = heroku.put_app(app['name'], 'name' => new_name)
      assert_equal(200, response.status)
      assert_equal(new_name, response.body['name'])

      heroku.delete_app(new_name)
    end
  end

end
