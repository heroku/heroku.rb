require File.expand_path("#{File.dirname(__FILE__)}/test_helper")

class TestAttachments < MiniTest::Unit::TestCase

  def test_get_attachments
    with_app do |app_data|
      response = heroku.get_attachments(app_data['name'])

      assert_equal(200, response.status)
      assert_equal(
        [],
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
