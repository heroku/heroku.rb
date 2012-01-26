require "#{File.dirname(__FILE__)}/test_helper"

class TestAddons < MiniTest::Unit::TestCase

  def test_delete_addon_addon_not_found
    with_app do |app_data|
      assert_raises(Heroku::Errors::Error) do
        heroku.delete_addon(app_data['name'], random_name)
      end
    end
  end

  def test_delete_addon_addon_not_installed
    with_app do |app_data|
      assert_raises(Heroku::Errors::Error) do
        heroku.delete_addon(app_data['name'], 'custom_domains:basic')
      end
    end
  end

  def test_delete_addon_app_not_found
    assert_raises(Heroku::Errors::NotFound) do
      heroku.delete_addon(random_name, 'logging:basic')
    end
  end

  def test_delete_addon
    with_app do |app_data|
      heroku.post_addon(app_data['name'], 'custom_domains:basic')
      response = heroku.delete_addon(app_data['name'], 'custom_domains:basic')

      assert_equal(200, response.status)
      assert_equal({
        'message' => nil,
        'price'   => 'free',
        'status'  => 'Uninstalled'
      }, response.body)
    end
  end

  def test_get_addons
    skip unless MOCK
    response = heroku.get_addons
    data = File.read("#{File.dirname(__FILE__)}/../lib/heroku/stubs/cache/get_addons.json")

    assert_equal(200, response.status)
    assert_equal(Heroku::OkJson.decode(data), response.body)
  end

  def test_get_addons_with_app
    with_app do |app_data|
      response = heroku.get_addons(app_data['name'])

      assert_equal(200, response.status)
      assert_equal([{
        'beta'        => false,
        'configured'  => true,
        'description' => 'Logging Basic',
        'name'        => 'logging:basic',
        'url'         => 'https://addons.heroku.com/addons/logging:basic',
        'state'       => 'public'
      },
      {
        'beta'        => false,
        'configured'  => true,
        'description' => 'Shared Database 5MB',
        'name'        => 'shared-database:5mb',
        'state'       => 'public',
        'url'         => nil
      }], response.body)
    end
  end

  def test_get_addons_with_app_app_not_found
    assert_raises(Heroku::Errors::NotFound) do
      heroku.get_addons(random_name)
    end
  end

  def test_post_addon
    with_app do |app_data|
      response = heroku.post_addon(app_data['name'], 'custom_domains:basic')

      assert_equal(200, response.status)
      assert_equal({
        'message' => nil,
        'price'   => 'free',
        'status'  => 'Installed'
      }, response.body)
    end
  end

  def test_post_addon_addon_already_installed
    with_app do |app_data|
      assert_raises(Heroku::Errors::Error) do
        heroku.post_addon(app_data['name'], 'logging:basic')
        heroku.post_addon(app_data['name'], 'logging:basic')
      end
    end
  end

  def test_post_addon_addon_type_already_installed
    with_app do |app_data|
      assert_raises(Heroku::Errors::Error) do
        heroku.post_addon(app_data['name'], 'logging:basic')
        heroku.post_addon(app_data['name'], 'logging:expanded')
      end
    end
  end

  def test_post_addon_addon_not_found
    with_app do |app_data|
      assert_raises(Heroku::Errors::Error) do
        heroku.post_addon(app_data['name'], random_name)
      end
    end
  end

  def test_post_addon_app_not_found
    assert_raises(Heroku::Errors::NotFound) do
      heroku.post_addon(random_name, 'shared-database:5mb')
    end
  end

  def test_put_addon
    with_app do |app_data|
      response = heroku.put_addon(app_data['name'], 'logging:expanded')

      assert_equal(200, response.status)
      assert_equal({
        'message' => nil,
        'price'   => 'free',
        'status'  => 'Updated'
      }, response.body)
    end
  end

  def test_put_addon_addon_already_installed
    with_app do |app_data|
      assert_raises(Heroku::Errors::Error) do
        heroku.post_addon(app_data['name'], 'logging:basic')
        heroku.put_addon(app_data['name'], 'logging:basic')
      end
    end
  end

  def test_put_addon_addon_not_found
    with_app do |app_data|
      assert_raises(Heroku::Errors::Error) do
        heroku.put_addon(app_data['name'], random_name)
      end
    end
  end

  def test_put_addon_addon_type_not_installed
    with_app do |app_data|
      assert_raises(Heroku::Errors::Error) do
        heroku.put_addon(app_data['name'], 'releases:basic')
      end
    end
  end

  def test_put_addon_app_not_found
    assert_raises(Heroku::Errors::NotFound) do
      heroku.put_addon(random_name, 'logging:basic')
    end
  end

end
