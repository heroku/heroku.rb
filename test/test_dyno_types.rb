require File.expand_path("#{File.dirname(__FILE__)}/test_helper")

class TestProcesses < MiniTest::Unit::TestCase

  def test_put_dyno_types_app_not_found
    assert_raises(Heroku::API::Errors::NotFound) do
      heroku.put_dyno_types(random_name, { 'web' => 2 })
    end
  end

  def test_put_dyno_types_scale_down
    with_app('stack' => 'cedar') do |app_data|
      heroku.put_dyno_types(app_data['name'], { 'web' => 2 })
      response = heroku.put_dyno_types(app_data['name'], { 'web' => 1 })

      assert_equal(200, response.status)
      assert_equal([{
        'command'   => '',
        'name'      => 'web',
        'quantity'  => 1
      }], response.body)
    end
  end

  def test_put_dyno_types_not_found
    assert_raises(Heroku::API::Errors::NotFound) do
      with_app('stack' => 'cedar') do |app_data|
        heroku.put_dyno_types(app_data['name'], 'run' => 2)
      end
    end
  end

  def test_put_dyno_types
    with_app('stack' => 'cedar') do |app_data|
      response = heroku.put_dyno_types(app_data['name'], { 'web' => 2 })

      assert_equal(200, response.status)
      assert_equal([{
        'command'   => '',
        'name'      => 'web',
        'quantity'  => 2
      }], response.body)
    end
  end

end
