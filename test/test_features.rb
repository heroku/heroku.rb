require File.expand_path("#{File.dirname(__FILE__)}/test_helper")

class TestFeatures < Minitest::Test

  def setup
    @feature_data ||= begin
      data = File.read("#{File.dirname(__FILE__)}/../lib/heroku/api/mock/cache/get_features.json")
      MultiJson.load(data).first
    end
  end

  def test_delete_feature
    with_app do |app_data|
      heroku.post_feature(@feature_data['name'], app_data['name'])
      response = heroku.delete_feature(@feature_data['name'], app_data['name'])

      assert_equal(200, response.status)
      assert_equal(@feature_data, response.body)
    end
  end

  def test_delete_feature_app_not_found
    assert_raises(Heroku::API::Errors::RequestFailed) do
      heroku.delete_feature(@feature_data['name'], random_name)
    end
  end

  def test_delete_feature_feature_not_found
    with_app do |app_data|
      assert_raises(Heroku::API::Errors::NotFound) do
        heroku.delete_feature(random_name, app_data['name'])
      end
    end
  end

  def test_get_features
    with_app do |app_data|
      response = heroku.get_features(app_data['name'])
      data = File.read("#{File.dirname(__FILE__)}/../lib/heroku/api/mock/cache/get_features.json")

      assert_equal(200, response.status)
      assert_equal(MultiJson.load(data), response.body)
    end
  end

  def test_get_feature
    with_app do |app_data|
      response = heroku.get_feature(@feature_data['name'], app_data['name'])

      assert_equal(200, response.status)
      assert_equal(@feature_data, response.body)
    end
  end

  def test_get_features_feature_not_found
    with_app do |app_data|
      assert_raises(Heroku::API::Errors::NotFound) do
        heroku.get_feature(random_name, app_data['name'])
      end
    end
  end

  def test_post_feature
    with_app do |app_data|
      response = heroku.post_feature(@feature_data['name'], app_data['name'])

      assert_equal(201, response.status)
      assert_equal(@feature_data.merge('enabled' => true), response.body)
    end
  end

  def test_post_feature_app_not_found
    assert_raises(Heroku::API::Errors::NotFound) do
      heroku.post_feature(@feature_data['name'], random_name)
    end
  end

  def test_post_feature_feature_not_found
    with_app do |app_data|
      assert_raises(Heroku::API::Errors::NotFound) do
        heroku.post_feature(random_name, app_data['name'])
      end
    end
  end

end
