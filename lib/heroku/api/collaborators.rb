module Heroku
  class API

    # DELETE /apps/:app/collaborators/:email
    def delete_collaborator(app, email)
      request(
        :expects  => 200,
        :method   => :delete,
        :path     => "/apps/#{app}/collaborators/#{email}"
      )
    end

    # GET /apps/:app/collaborators
    def get_collaborators(app)
      request(
        :expects  => 200,
        :method   => :get,
        :path     => "/apps/#{app}/collaborators"
      )
    end

    # POST /apps/:app/collaborators
    def post_collaborator(app, email)
      request(
        :expects  => [200, 201],
        :method   => :post,
        :path     => "/apps/#{app}/collaborators",
        :query    => {'collaborator[email]' => email}
      )
    end

  end
end
