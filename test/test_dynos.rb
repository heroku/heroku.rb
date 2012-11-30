require File.expand_path("#{File.dirname(__FILE__)}/test_helper")

class TestProcesses < MiniTest::Unit::TestCase

  def test_get_dynos
    with_app do |app_data|
      response = heroku.get_dynos(app_data['name'])
      ps = response.body.first

      assert_equal(200, response.status)
      assert_equal(app_data['id'], ps['app']['id'])
      assert_equal(false, ps['attached'])
      assert_equal('thin -p $PORT -e $RACK_ENV -R $HEROKU_RACK start', ps['command'])
      # elapsed
      # id
      assert_equal('web.1', ps['name'])
      assert_equal('created', ps['state'])
      assert_equal('web', ps['type']['name'])
    end
  end

  def test_get_dynos_app_not_found
    assert_raises(Heroku::API::Errors::NotFound) do
      heroku.get_dynos(random_name)
    end
  end

  def test_post_dynos
    with_app do |app_data|
      command = 'pwd'
      response = heroku.post_dynos(app_data['name'], command)
      ps = response.body

      assert_equal(200, response.status)
      assert_equal(app_data['id'], ps['app']['id'])
      assert_equal(false, ps['attached'])
      assert_equal('pwd', ps['command'])
      # elapsed
      # id
      assert_equal('run.1', ps['name'])
      assert_includes(['created', 'starting'], ps['state'])
      assert_equal('run', ps['type']['name'])
    end
  end

  def test_post_dynos_with_attach
    with_app do |app_data|
      command = 'pwd'
      response = heroku.post_dynos(app_data['name'], command, 'attach' => true)
      ps = response.body

      assert_equal(200, response.status)
      assert_equal(app_data['id'], ps['app']['id'])
      assert_equal(true, ps['attached'])
      assert_equal('pwd', ps['command'])
      # elapsed
      # id
      assert_equal('run.1', ps['name'])
      assert_includes(['created', 'starting'], ps['state'])
      assert_equal('run', ps['type']['name'])
    end
  end

  def test_post_dynos_app_not_found
    assert_raises(Heroku::API::Errors::NotFound) do
      heroku.post_dynos(random_name, 'pwd')
    end
  end

  def test_delete_dynos_restart
    with_app do |app_data|
      response = heroku.delete_dynos(app_data['name'])
      ps = response.body.first

      assert_equal(200, response.status)
      assert_equal(app_data['id'], ps['app']['id'])
      assert_equal(nil, ps['attached'])
      assert_equal('', ps['command'])
      # elapsed
      # id
      assert_equal('web.1', ps['name'])
      assert_equal('created', ps['state'])
      assert_equal('web', ps['type']['name'])
    end
  end

  def test_delete_dynos_restart_with_ps
    with_app do |app_data|
      response = heroku.delete_dynos(app_data['name'], 'ps' => 'web.1')
      ps = response.body.first

      assert_equal(200, response.status)
      assert_equal(app_data['id'], ps['app']['id'])
      assert_equal(nil, ps['attached'])
      assert_equal('', ps['command'])
      # elapsed
      # id
      assert_equal('web.1', ps['name'])
      assert_equal('created', ps['state'])
      assert_equal('web', ps['type']['name'])
    end
  end

  def test_delete_dynos_restart_with_type
    with_app do |app_data|
      response = heroku.delete_dynos(app_data['name'], 'type' => 'web')
      ps = response.body.first

      assert_equal(200, response.status)
      assert_equal(app_data['id'], ps['app']['id'])
      assert_equal(nil, ps['attached'])
      assert_equal('', ps['command'])
      # elapsed
      # id
      assert_equal('web.1', ps['name'])
      assert_equal('created', ps['state'])
      assert_equal('web', ps['type']['name'])
    end
  end

  def test_delete_dynos_restart_app_not_found
    assert_raises(Heroku::API::Errors::NotFound) do
      heroku.delete_dynos(random_name)
    end
  end

  def test_put_dynos
    with_app(:stack => 'bamboo-mri-1.9.2')  do |app_data|
      dynos = 1
      response = heroku.put_dynos(app_data['name'], dynos)

      assert_equal(200, response.status)
      assert_equal({
        'name' => app_data['name'],
        'dynos' => dynos
      }, response.body)
    end
  end

  def test_put_dynos_app_not_found
    assert_raises(Heroku::API::Errors::NotFound) do
      heroku.put_dynos(random_name, 1)
    end
  end

  def test_put_dynos_with_cedar
    assert_raises(Heroku::API::Errors::RequestFailed) do
      with_app('stack' => 'cedar') do |app_data|
        heroku.put_dynos(app_data['name'], 2)
      end
    end
  end

  def test_put_workers
    with_app(:stack => 'bamboo-mri-1.9.2')  do |app_data|
      workers = 1
      response = heroku.put_workers(app_data['name'], workers)

      assert_equal(200, response.status)
      assert_equal({
        'name' => app_data['name'],
        'workers' => workers
      }, response.body)
    end
  end

  def test_put_workers_app_not_found
    assert_raises(Heroku::API::Errors::NotFound) do
      heroku.put_workers(random_name, 1)
    end
  end

  def test_put_workers_with_cedar
    assert_raises(Heroku::API::Errors::RequestFailed) do
      with_app('stack' => 'cedar') do |app_data|
        heroku.put_workers(app_data['name'], 2)
      end
    end
  end

end
