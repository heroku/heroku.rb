require "#{File.dirname(__FILE__)}/test_helper"

class TestDomains < MiniTest::Unit::TestCase

  def test_delete_domain_app_not_found
    assert_raises(Excon::Errors::NotFound) do
      heroku.delete_domain(random_name, 'example.com')
    end
  end

  def test_delete_domain
    with_app do |app_data|
      heroku.post_addon(app_data['name'], 'custom_domains:basic')
      heroku.post_domain(app_data['name'], 'example.com')
      response = heroku.delete_domain(app_data['name'], 'example.com')

      assert_equal(200, response.status)
      assert_equal({}, response.body)
    end
  end

  def test_get_domains
    with_app do |app_data|
      response = heroku.get_domains(app_data['name'])

      assert_equal(200, response.status)
      assert_equal([], response.body)
    end
  end

  def test_get_domains_app_not_found
    assert_raises(Excon::Errors::NotFound) do
      heroku.get_domains(random_name)
    end
  end

  def test_post_domain
    with_app do |app_data|
      heroku.post_addon(app_data['name'], 'custom_domains:basic')
      response = heroku.post_domain(app_data['name'], 'example.com')

      assert_equal(201, response.status)
      assert_equal({'domain' => 'example.com'}, response.body)

      heroku.delete_domain(app_data['name'], 'example.com')
    end
  end

  def test_post_domain_addon_not_installed
    with_app do |app_data|
      assert_raises(Excon::Errors::UnprocessableEntity) do
        heroku.post_domain(app_data['name'], 'example.com')
      end
    end
  end

  def test_post_domain_app_not_found
    assert_raises(Excon::Errors::NotFound) do
      heroku.post_domain(random_name, 'example.com')
    end
  end

end
