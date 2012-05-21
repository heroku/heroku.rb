require File.expand_path("#{File.dirname(__FILE__)}/test_helper")

class TestProcesses < MiniTest::Unit::TestCase

  def test_get_ps
    with_app do |app_data|
      response = heroku.get_ps(app_data['name'])
      ps = response.body.first

      assert_equal(200, response.status)
      assert_equal('up', ps['action'])
      assert_equal(app_data['name'], ps['app_name'])
      assert_equal(false, ps['attached'])
      assert_equal('thin -p $PORT -e $RACK_ENV -R $HEROKU_RACK start', ps['command'])
      # elapsed
      # pretty_state
      assert_equal('web.1', ps['process'])
      assert_equal(nil, ps['rendevous_url'])
      assert_equal('NONE', ps['slug'])
      assert_equal('created', ps['state'])
      # transitioned_at
      assert_equal('Dyno', ps['type'])
      # upid
    end
  end

  def test_get_ps_app_not_found
    assert_raises(Heroku::API::Errors::NotFound) do
      heroku.get_ps(random_name)
    end
  end

  def test_post_ps
    with_app do |app_data|
      command = 'pwd'
      response = heroku.post_ps(app_data['name'], command)
      ps = response.body

      assert_equal(200, response.status)
      assert_equal('complete', ps['action'])
      refute(ps['attached'])
      assert_equal(command, ps['command'])
      # elapsed
      # pretty_state
      assert_equal('run.1', ps['process'])
      assert_nil(ps['rendevous_url'])
      assert_equal('NONE', ps['slug'])
      # depending on timing it will be one of these two states
      assert_includes(['created', 'starting'], ps['state'])
      # transitioned_at
      assert_equal('Ps', ps['type'])
      # upid
    end
  end

  def test_post_ps_with_attach
    with_app do |app_data|
      command = 'pwd'
      response = heroku.post_ps(app_data['name'], command, 'attach' => true)
      ps = response.body

      assert_equal(200, response.status)
      assert_equal('complete', ps['action'])
      assert(ps['attached'])
      assert_equal(command, ps['command'])
      # elapsed
      # pretty_state
      assert_equal('run.1', ps['process'])
      refute_nil(ps['rendezvous_url'])
      assert_equal('NONE', ps['slug'])
      # depending on timing it will be one of these two states
      assert_includes(['created', 'starting'], ps['state'])
      # transitioned_at
      assert_equal(nil, ps['type'])
      # upid
    end
  end

  def test_post_ps_app_not_found
    assert_raises(Heroku::API::Errors::NotFound) do
      heroku.post_ps(random_name, 'pwd')
    end
  end

  def test_post_ps_restart
    with_app do |app_data|
      response = heroku.post_ps_restart(app_data['name'])

      assert_equal(200, response.status)
      assert_equal('ok', response.body)
    end
  end

  def test_post_ps_restart_with_ps
    with_app do |app_data|
      response = heroku.post_ps_restart(app_data['name'], 'ps' => 'web.1')

      assert_equal(200, response.status)
      assert_equal('ok', response.body)
    end
  end

  def test_post_ps_restart_with_type
    with_app do |app_data|
      response = heroku.post_ps_restart(app_data['name'], 'type' => 'web')

      assert_equal(200, response.status)
      assert_equal('ok', response.body)
    end
  end

  def test_post_ps_restart_app_not_found
    assert_raises(Heroku::API::Errors::NotFound) do
      heroku.post_ps_restart(random_name)
    end
  end

  def test_post_ps_scale_app_not_found
    assert_raises(Heroku::API::Errors::NotFound) do
      heroku.post_ps_scale(random_name, 'web', 2)
    end
  end

  def test_post_ps_scale_down
    with_app('stack' => 'cedar') do |app_data|
      heroku.post_ps_scale(app_data['name'], 'web', 2)
      response = heroku.post_ps_scale(app_data['name'], 'web', 1)

      assert_equal(200, response.status)
      assert_equal("1", response.body)
    end
  end

  def test_post_ps_scale_type_not_found
    assert_raises(Heroku::API::Errors::RequestFailed) do
      with_app('stack' => 'cedar') do |app_data|
        heroku.post_ps_scale(app_data['name'], 'run', 2)
      end
    end
  end

  def test_post_ps_scale_up
    with_app('stack' => 'cedar') do |app_data|
      response = heroku.post_ps_scale(app_data['name'], 'web', 2)

      assert_equal(200, response.status)
      assert_equal("2", response.body)
    end
  end

  def test_post_ps_scale_without_cedar
    assert_raises(Heroku::API::Errors::RequestFailed) do
      with_app do |app_data|
        heroku.post_ps_scale(app_data['name'], 'web', 2)
      end
    end
  end

  def test_post_ps_stop
    assert_raises(Heroku::API::Errors::RequestFailed) do
      with_app do |app_data|
        heroku.post_ps_stop(app_data['name'], {})
      end
    end
  end

  def test_post_ps_stop_with_ps
    with_app do |app_data|
      response = heroku.post_ps_stop(app_data['name'], 'ps' => 'web.1')

      assert_equal(200, response.status)
      assert_equal('ok', response.body)
    end
  end

  def test_post_ps_stop_with_type
    with_app do |app_data|
      response = heroku.post_ps_stop(app_data['name'], 'type' => 'web')

      assert_equal(200, response.status)
      assert_equal('ok', response.body)
    end
  end

  def test_post_ps_stop_app_not_found
    assert_raises(Heroku::API::Errors::NotFound) do
      heroku.post_ps_stop(random_name, {})
    end
  end

  def test_put_dynos
    with_app do |app_data|
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
    with_app do |app_data|
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
