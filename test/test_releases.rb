require "#{File.dirname(__FILE__)}/test_helper"

class TestReleases < MiniTest::Unit::TestCase

  def test_get_releases
    with_app do |app_data|
      heroku.post_addon(app_data['name'], 'releases:basic')
      response = heroku.get_releases(app_data['name'])

      assert_equal(200, response.status)
      # body assertion?
    end
  end

  def test_get_releases_app_not_found
    assert_raises(Excon::Errors::NotFound) do
      heroku.get_releases(random_name)
    end
  end

  def test_get_releases_addon_not_installed
    with_app do |app_data|
      assert_raises(Excon::Errors::UnprocessableEntity) do
        heroku.get_releases(app_data['name'])
      end
    end
  end

  def test_get_release
    with_app do |app_data|
      heroku.post_addon(app_data['name'], 'releases:basic')
      current = heroku.get_releases(app_data['name']).body.last['name']
      response = heroku.get_release(app_data['name'], current)

      assert_equal(200, response.status)
      # body assertion?
    end
  end

  def test_get_release_app_not_found
    assert_raises(Excon::Errors::NotFound) do
      heroku.get_release(random_name, 'v2')
    end
  end

  def test_get_release_addon_not_installed
    with_app do |app_data|
      assert_raises(Excon::Errors::UnprocessableEntity) do
        heroku.get_release(app_data['name'], 'v2')
      end
    end
  end

  def test_get_release_release_not_found
    assert_raises(Excon::Errors::NotFound) do
      heroku.get_release(random_name, 'v0')
    end
  end

  def test_post_release
    with_app do |app_data|
      heroku.post_addon(app_data['name'], 'releases:basic')
      current = heroku.get_releases(app_data['name']).body.last['name']
      response = heroku.post_release(app_data['name'], current)

      assert_equal(200, response.status)
      # body assertion?
    end
  end

  def test_post_release_app_not_found
    assert_raises(Excon::Errors::NotFound) do
      heroku.post_release(random_name, 'v3')
    end
  end

  def test_post_release_addon_not_installed
    with_app do |app_data|
      assert_raises(Excon::Errors::UnprocessableEntity) do
        heroku.post_release(app_data['name'], 'v3')
      end
    end
  end

  def test_post_release_release_not_found
    assert_raises(Excon::Errors::NotFound) do
      heroku.post_release(random_name, 'v0')
    end
  end

end
