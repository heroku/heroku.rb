require File.expand_path("#{File.dirname(__FILE__)}/test_helper")

class TestAddons < MiniTest::Unit::TestCase

  def test_delete_addon_addon_not_found
    with_app do |app_data|
      assert_raises(Heroku::API::Errors::RequestFailed) do
        heroku.delete_addon(app_data['name'], random_name)
      end
    end
  end

  def test_delete_addon_addon_not_installed
    with_app do |app_data|
      assert_raises(Heroku::API::Errors::RequestFailed) do
        heroku.delete_addon(app_data['name'], 'custom_domains:basic')
      end
    end
  end

  def test_delete_addon_app_not_found
    assert_raises(Heroku::API::Errors::NotFound) do
      heroku.delete_addon(random_name, 'logging:basic')
    end
  end

  def test_delete_addon
    with_app do |app_data|
      heroku.post_addon(app_data['name'], 'deployhooks:http')
      response = heroku.delete_addon(app_data['name'], 'deployhooks:http')

      assert_equal(200, response.status)
      assert_equal({
        "id"                => "deployhooks",
        "name"              => "Deploy Hooks",
        "plans"             => [
          {
            "id"      => "deployhooks:http",
            "message" => nil,
            "name"    => "HTTP Hook",
            "sso_url" => nil,
            "state"   => "public",
            "status"  => "install"
          }
        ],
        "terms_of_service"  => false,
        "url"               => "http://devcenter.heroku.com/articles/deploy-hooks#http-post-hook"
      }, response.body)
    end
  end

  def test_get_addons
    response = heroku.get_addons
    data = File.read("#{File.dirname(__FILE__)}/../lib/heroku/api/mock/cache/get_addons.json")

    assert_equal(200, response.status)
    assert_equal(Heroku::API::OkJson.decode(data), response.body)
  end

  def test_get_addons_with_app
    with_app do |app_data|
      response = heroku.get_addons(app_data['name'])

      assert_equal(200, response.status)
      assert_equal([], response.body)
    end
  end

  def test_get_addons_with_app_app_not_found
    assert_raises(Heroku::API::Errors::NotFound) do
      heroku.get_addons(random_name)
    end
  end

  def test_post_addon
    with_app do |app_data|
      response = heroku.post_addon(app_data['name'], 'deployhooks:http')

      assert_equal(200, response.status)
      assert_equal({
        "id"                => "deployhooks",
        "name"              => "Deploy Hooks",
        "plans"             => [
          {
            "id"      => "deployhooks:http",
            "message" => nil,
            "name"    => "HTTP Hook",
            "sso_url" => nil,
            "state"   => "public",
            "status"  => "installed"
          }
        ],
        "terms_of_service"  => false,
        "url"               => "http://devcenter.heroku.com/articles/deploy-hooks#http-post-hook"
      }, response.body)
    end
  end

  def test_post_addon_with_config
    with_app do |app_data|
      response = heroku.post_addon(app_data['name'], 'deployhooks:http', {"url"=>"http://example.com"})

      assert_equal(200, response.status)
      assert_equal({
        "id"                => "deployhooks",
        "name"              => "Deploy Hooks",
        "plans"             => [
          {
            "id"      => "deployhooks:http",
            "message" => nil,
            "name"    => "HTTP Hook",
            "sso_url" => nil,
            "state"   => "public",
            "status"  => "installed"
          }
        ],
        "terms_of_service"  => false,
        "url"               => "http://devcenter.heroku.com/articles/deploy-hooks#http-post-hook"
      }, response.body)
    end
  end

  def test_post_addon_addon_already_installed
    with_app do |app_data|
      assert_raises(Heroku::API::Errors::RequestFailed) do
        heroku.post_addon(app_data['name'], 'logging:basic')
        heroku.post_addon(app_data['name'], 'logging:basic')
      end
    end
  end

  def test_post_addon_addon_type_already_installed
    with_app do |app_data|
      assert_raises(Heroku::API::Errors::RequestFailed) do
        heroku.post_addon(app_data['name'], 'logging:basic')
        heroku.post_addon(app_data['name'], 'logging:expanded')
      end
    end
  end

  def test_post_addon_addon_not_found
    with_app do |app_data|
      assert_raises(Heroku::API::Errors::NotFound) do
        heroku.post_addon(app_data['name'], random_name)
      end
    end
  end

  def test_post_addon_app_not_found
    assert_raises(Heroku::API::Errors::NotFound) do
      heroku.post_addon(random_name, 'shared-database:5mb')
    end
  end

  def test_put_addon
    with_app do |app_data|
      response = heroku.post_addon(app_data['name'], 'pgbackups:basic')
      response = heroku.put_addon(app_data['name'], 'pgbackups:plus')

      assert_equal(200, response.status)
      assert_equal({
        "id"                => "pgbackups",
        "name"              => "Pgbackups",
        "plans"             => [
          {
            "id"      => "pgbackups:plus",
            "message" => "Plan upgraded",
            "name"    => "PG Backups Plus",
            "sso_url" => nil,
            "state"   => "public",
            "status"  => "installed"
          }
        ],
        "terms_of_service"  => false,
        "url"               => nil
      }, response.body)
    end
  end

  def test_put_addon_addon_already_installed
    with_app do |app_data|
      assert_raises(Heroku::API::Errors::RequestFailed) do
        heroku.post_addon(app_data['name'], 'logging:basic')
        heroku.put_addon(app_data['name'], 'logging:basic')
      end
    end
  end

  def test_put_addon_addon_not_found
    with_app do |app_data|
      assert_raises(Heroku::API::Errors::NotFound) do
        heroku.put_addon(app_data['name'], random_name)
      end
    end
  end

  def test_put_addon_addon_type_not_installed
    with_app do |app_data|
      assert_raises(Heroku::API::Errors::RequestFailed) do
        heroku.put_addon(app_data['name'], 'releases:basic')
      end
    end
  end

  def test_put_addon_app_not_found
    assert_raises(Heroku::API::Errors::NotFound) do
      heroku.put_addon(random_name, 'logging:basic')
    end
  end

end
