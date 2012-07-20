require File.expand_path("#{File.dirname(__FILE__)}/test_helper")

class TestApps < MiniTest::Unit::TestCase

  def test_delete_app
    with_app do |app_data|
      response = heroku.delete_app(app_data['name'])
      assert_equal({}, response.body)
      assert_equal(200, response.status)
    end
  end

  def test_delete_app_not_found
    assert_raises(Heroku::API::Errors::NotFound) do
      heroku.delete_app(random_name)
    end
  end

  def test_get_apps
    with_app do |app_data|
      response = heroku.get_apps
      assert_equal(200, response.status)
      assert(response.body.detect {|app| app['name'] == app_data['name']})
    end
  end

  def test_get_app
    with_app do |app_data|
      response = heroku.get_app(app_data['name'])
      assert_equal(200, response.status)
      assert_equal(app_data['name'], response.body['name'])
    end
  end

  def test_get_app_not_found
    assert_raises(Heroku::API::Errors::NotFound) do
      heroku.get_app(random_name)
    end
  end

  def test_get_app_maintenance
    with_app do |app_data|
      response = heroku.get_app_maintenance(app_data['name'])

      assert_equal(200, response.status)
      assert_equal({'maintenance' => false}, response.body)

      heroku.post_app_maintenance(app_data['name'], '1')
      response = heroku.get_app_maintenance(app_data['name'])

      assert_equal(200, response.status)
      assert_equal({'maintenance' => true}, response.body)
    end
  end

  def test_post_app
    response = heroku.post_app

    assert_equal(202, response.status)

    heroku.delete_app(response.body['name'])
  end

  def test_post_app_with_name
    name = random_name
    response = heroku.post_app('name' => name)

    assert_equal(202, response.status)
    assert_equal(name, response.body['name'])

    heroku.delete_app(name)
  end

  def test_post_app_with_duplicate_name
    name = random_name
    response = heroku.post_app('name' => name)

    assert_raises(Heroku::API::Errors::RequestFailed) do
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
    name = random_name
    assert_raises(Heroku::API::Errors::NotFound) do
      heroku.put_app(name, 'name' => random_name)
    end
  end

  def test_put_app_with_name
    with_app do |app_data|
      new_name = random_name
      response = heroku.put_app(app_data['name'], 'name' => new_name)

      assert_equal(200, response.status)
      assert_equal({'name' => new_name}, response.body)

      heroku.delete_app(new_name)
    end
  end

  def test_put_app_with_transfer_owner_non_collaborator
    with_app do |app_data|
      assert_raises(Heroku::API::Errors::RequestFailed) do
        heroku.put_app(app_data['name'], 'transfer_owner' => 'wesley@heroku.com')
      end
    end
  end

  def test_put_app_with_transfer_owner
    with_app do |app_data|
      email_address = 'wesley@heroku.com'
      heroku.post_collaborator(app_data['name'], email_address)
      response = heroku.put_app(app_data['name'], 'transfer_owner' => email_address)

      assert_equal(200, response.status)
      assert_equal({'name' => app_data['name']}, response.body)

      heroku.delete_collaborator(app_data['name'], email_address)
    end
  end

  def test_post_app_maintenance
    with_app do |app_data|
      response = heroku.post_app_maintenance(app_data['name'], '1')

      assert_equal(200, response.status)
      assert_equal("", response.body)

      response = heroku.post_app_maintenance(app_data['name'], '0')

      assert_equal(200, response.status)
      assert_equal("", response.body)
    end
  end
end
