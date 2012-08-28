require File.expand_path("#{File.dirname(__FILE__)}/test_helper")

class TestAttachments < MiniTest::Unit::TestCase

  def test_get_attachments
    with_app do |app_data|
      response = heroku.get_attachments(app_data['name'])

      assert_equal(200, response.status)
      assert_equal(
          [{
            'name' => 'HEROKU_POSTGRESQL_BROWN',
            'app' => {
              'name' => app_data['name'],
              'id' => "app#{app_data['id']}@heroku.com",
              'owner' => app_data['owner_email']
            },
            'config_var' => 'HEROKU_POSTGRESQL_BROWN_URL',
            'resource' => {
              'name' => 'advising-nobly-1989',
              'type' => 'heroku-postgresql:crane',
              'value' => 'postgres://username:password@host:5432/dbname',
              'billing_app' => {
                'name' => app_data['name'],
                'id' => "app#{app_data['id']}@heroku.com",
                'owner' => app_data['owner_email']
              },
              'sso_url' => nil
            }
          }],
        response.body
      )
    end
  end

  def test_get_attachments_app_not_found
    assert_raises(Heroku::API::Errors::NotFound) do
      heroku.get_attachments(random_name)
    end
  end

end
