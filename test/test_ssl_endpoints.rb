require File.expand_path("#{File.dirname(__FILE__)}/test_helper")

class TestSslEndpoints < MiniTest::Unit::TestCase

  def test_delete_ssl_endpoint
    skip if MOCK
    with_app do |app_data|
      heroku.post_addon(app_data['name'], 'ssl:endpoint')
      ssl_endpoint_data = heroku.post_ssl_endpoint(app_data['name'], data_server_crt, data_server_key).body

      response = heroku.delete_ssl_endpoint(app_data['name'], ssl_endpoint_data['cname'])

      assert_equal(' ', response.body)
      assert_equal(200, response.status)
    end
  end

  def test_delete_ssl_endpoint_app_not_found
    skip if MOCK
    assert_raises(Heroku::API::Errors::NotFound) do
      heroku.delete_ssl_endpoint(random_name, 'key')
    end
  end

  def test_get_ssl_endpoint
    skip if MOCK
    with_app do |app_data|
      heroku.post_addon(app_data['name'], 'ssl:endpoint')
      ssl_endpoint_data = heroku.post_ssl_endpoint(app_data['name'], data_server_crt, data_server_key).body

      response = heroku.get_ssl_endpoint(app_data['name'], ssl_endpoint_data['cname'])

      data = response.body['ssl_cert']
      assert_equal(false, data['ca_signed?'])
      assert_equal(true, data['self_signed?'])
      assert_equal(['geemus (wesley beary)'], data['cert_domains'])
      assert_equal('2013/07/30 15:19:30 -0700', data['expires_at'])
      assert_equal('/C=US/O=Heroku/CN=geemus (Wesley Beary)/emailAddress=wesley@heroku.com', data['issuer'])
      assert_equal('2012/07/30 15:19:30 -0700', data['starts_at'])
      assert_equal('/C=US/O=Heroku/CN=geemus (Wesley Beary)/emailAddress=wesley@heroku.com', data['subject'])
      assert_equal(200, response.status)
    end
  end

  def test_get_ssl_endpoints
    skip if MOCK
    with_app do |app_data|
      heroku.post_addon(app_data['name'], 'ssl:endpoint')
      heroku.post_ssl_endpoint(app_data['name'], data_server_crt, data_server_key)

      response = heroku.get_ssl_endpoints(app_data['name'])

      data = response.body.first['ssl_cert']
      assert_equal(false, data['ca_signed?'])
      assert_equal(true, data['self_signed?'])
      assert_equal(['geemus (wesley beary)'], data['cert_domains'])
      assert_equal('2013/07/30 15:19:30 -0700', data['expires_at'])
      assert_equal('/C=US/O=Heroku/CN=geemus (Wesley Beary)/emailAddress=wesley@heroku.com', data['issuer'])
      assert_equal('2012/07/30 15:19:30 -0700', data['starts_at'])
      assert_equal('/C=US/O=Heroku/CN=geemus (Wesley Beary)/emailAddress=wesley@heroku.com', data['subject'])
      assert_equal(200, response.status)
    end
  end

  def test_post_ssl_endpoint
    skip if MOCK
    with_app do |app_data|
      heroku.post_addon(app_data['name'], 'ssl:endpoint')

      response = heroku.post_ssl_endpoint(app_data['name'], data_server_crt, data_server_key)

      data = response.body['ssl_cert']
      assert_equal(false, data['ca_signed?'])
      assert_equal(true, data['self_signed?'])
      assert_equal(['geemus (wesley beary)'], data['cert_domains'])
      assert_equal('2013/07/30 15:19:30 -0700', data['expires_at'])
      assert_equal('/C=US/O=Heroku/CN=geemus (Wesley Beary)/emailAddress=wesley@heroku.com', data['issuer'])
      assert_equal('2012/07/30 15:19:30 -0700', data['starts_at'])
      assert_equal('/C=US/O=Heroku/CN=geemus (Wesley Beary)/emailAddress=wesley@heroku.com', data['subject'])
      assert_equal(200, response.status)
    end
  end

  def test_post_ssl_endpoint_rollback
    skip if MOCK
    with_app do |app_data|
      heroku.post_addon(app_data['name'], 'ssl:endpoint')
      ssl_endpoint_data = heroku.post_ssl_endpoint(app_data['name'], data_server_crt, data_server_key).body
      heroku.put_ssl_endpoint(app_data['name'], ssl_endpoint_data['cname'], data_server_crt, data_server_key)

      response = heroku.post_ssl_endpoint_rollback(app_data['name'], ssl_endpoint_data['cname'])

      data = response.body['ssl_cert']
      assert_equal(false, data['ca_signed?'])
      assert_equal(true, data['self_signed?'])
      assert_equal(['geemus (wesley beary)'], data['cert_domains'])
      assert_equal('2013/07/30 15:19:30 -0700', data['expires_at'])
      assert_equal('/C=US/O=Heroku/CN=geemus (Wesley Beary)/emailAddress=wesley@heroku.com', data['issuer'])
      assert_equal('2012/07/30 15:19:30 -0700', data['starts_at'])
      assert_equal('/C=US/O=Heroku/CN=geemus (Wesley Beary)/emailAddress=wesley@heroku.com', data['subject'])
      assert_equal(200, response.status)
    end
  end

  def test_put_ssl_endpoint
    skip if MOCK
    with_app do |app_data|
      heroku.post_addon(app_data['name'], 'ssl:endpoint')
      ssl_endpoint_data = heroku.post_ssl_endpoint(app_data['name'], data_server_crt, data_server_key).body

      response = heroku.put_ssl_endpoint(app_data['name'], ssl_endpoint_data['cname'], data_server_crt, data_server_key)

      data = response.body['ssl_cert']
      assert_equal(false, data['ca_signed?'])
      assert_equal(true, data['self_signed?'])
      assert_equal(['geemus (wesley beary)'], data['cert_domains'])
      assert_equal('2013/07/30 15:19:30 -0700', data['expires_at'])
      assert_equal('/C=US/O=Heroku/CN=geemus (Wesley Beary)/emailAddress=wesley@heroku.com', data['issuer'])
      assert_equal('2012/07/30 15:19:30 -0700', data['starts_at'])
      assert_equal('/C=US/O=Heroku/CN=geemus (Wesley Beary)/emailAddress=wesley@heroku.com', data['subject'])
      assert_equal(200, response.status)
    end
  end

end
