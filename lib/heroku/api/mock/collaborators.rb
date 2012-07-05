module Heroku
  class API
    module Mock

      # stub DELETE /apps/:app/collaborators/:email
      Excon.stub(:expects => 200, :method => :delete, :path => %r{^/apps/([^/]+)/collaborators/([^/]+)$}) do |params|
        request_params, mock_data = parse_stub_params(params)
        app, email, _ = request_params[:captures][:path]
        with_mock_app(mock_data, app) do
          if collaborator_data = get_mock_collaborator(mock_data, app, email)
            mock_data[:collaborators][app].delete(collaborator_data)
            {
              :body   => "#{email} has been removed as collaborator on #{app}",
              :status => 200
            }
          else
            { :body => 'User not found.', :status => 404 }
          end
        end
      end

      # stub GET /apps/:app/:collaborators
      Excon.stub(:expects => 200, :method => :get, :path => %r{^/apps/([^/]+)/collaborators}) do |params|
        request_params, mock_data = parse_stub_params(params)
        app, _ = request_params[:captures][:path]
        with_mock_app(mock_data, app) do
          {
            :body   => Heroku::API::OkJson.encode(mock_data[:collaborators][app]),
            :status => 200
          }
        end
      end

      # stub POST /apps/:app/collaborators
      Excon.stub(:expects => [200, 201], :method => :post, :path => %r{^/apps/([^/]+)/collaborators}) do |params|
        request_params, mock_data = parse_stub_params(params)
        app, _ = request_params[:captures][:path]
        email = request_params[:query]['collaborator[email]']
        with_mock_app(mock_data, app) do
          mock_data[:collaborators][app] |= [{'access' => 'edit', 'email' => email, 'name' => nil}]
          {
            :body   => "#{email} added as a collaborator on #{app}.",
            :status => 201
          }
          # Existing user response
          #{
          #  :body => "#{email} added as a collaborator on #{app}",
          #  :status => 200
          #}
        end
      end

    end
  end
end
