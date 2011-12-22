require "#{File.dirname(__FILE__)}/test_helper"

class TestCollaborators < MiniTest::Unit::TestCase

  def test_delete_collaborator
    with_app do |app_data|
      email_address = random_email_address
      heroku.post_collaborator(app_data['name'], email_address)

      response = heroku.delete_collaborator(app_data['name'], email_address)

      assert_equal(200, response.status)
      assert_equal(
        "#{email_address} has been removed as collaborator on #{app_data['name']}",
        response.body
      )
    end
  end

  def test_delete_collaborator_app_not_found
    assert_raises(Excon::Errors::NotFound) do
      heroku.delete_collaborator(random_name, random_email_address)
    end
  end

  def test_delete_collaborator_user_not_found
    with_app do |app_data|
      assert_raises(Excon::Errors::NotFound) do
        heroku.delete_collaborator(app_data['name'], random_email_address)
      end
    end
  end

  def test_get_collaborators
    with_app do |app_data|
      response = heroku.get_collaborators(app_data['name'])

      assert_equal(200, response.status)
      assert_equal(
        [{'access' => 'edit', 'email' => 'email@example.com'}],
        response.body
      )
    end
  end

  def test_get_collaborators_app_not_found
    assert_raises(Excon::Errors::NotFound) do
      heroku.get_collaborators(random_name)
    end
  end

  def test_post_collaborator
    with_app do |app_data|
      email_address = random_email_address
      response = heroku.post_collaborator(app_data['name'], email_address)

      assert_equal(200, response.status)
      assert_equal(
        "An invitation has been sent to #{email_address} for them to join Heroku and become a collaborator on #{app_data['name']}.",
        response.body
      )

      heroku.delete_collaborator(app_data['name'], email_address)
    end
  end

  def test_post_collaborator_app_not_found
    assert_raises(Excon::Errors::NotFound) do
      heroku.post_collaborator(random_name, random_email_address)
    end
  end

end
