module Heroku
  class API < Excon::Connection
    module Mock

      # stub DELETE /apps/:app
      Excon.stub(:expects => 200, :method => :delete, :path => %r{^/apps/([^/]+)$} ) do |params|
        request_params, mock_data = parse_stub_params(params)
        app, _ = request_params[:captures][:path]
        with_mock_app(mock_data, app) do |app_data|
          mock_data[:addons].delete(app)
          mock_data[:apps].delete(app_data)
          mock_data[:collaborators].delete(app)
          mock_data[:config_vars].delete(app)
          mock_data[:domains].delete(app)
          {
            :body   => Heroku::OkJson.encode({}),
            :status => 200
          }
        end
      end

      # stub GET /apps/
      Excon.stub(:expects => 200, :method => :get, :path => '/apps') do |params|
        request_params, mock_data = parse_stub_params(params)
        {
          :body   => Heroku::OkJson.encode(mock_data[:apps]),
          :status => 200
        }
      end

      # stub GET /apps/:app
      Excon.stub(:expects => 200, :method => :get, :path => %r{^/apps/([^/]+)$} ) do |params|
        request_params, mock_data = parse_stub_params(params)
        app, _ = request_params[:captures][:path]
        with_mock_app(mock_data, app) do |app_data|
          {
            :body   => Heroku::OkJson.encode(app_data),
            :status => 200
          }
        end
      end

      # stub POST /apps
      Excon.stub(:expects => 202, :method => :post, :path => '/apps') do |params|
        request_params, mock_data = parse_stub_params(params)
        app = request_params[:query].has_key?('app[name]') && request_params[:query]['app[name]'] || "generated-name-#{rand(999)}"

        if get_mock_app(mock_data, app)
          {
            :body => Heroku::OkJson.encode('error' => 'Name is already taken'),
            :status => 422
          }
        else
          app_data = {
            'created_at'          => timestamp,
            'create_status'       => 'complete',
            'id'                  => rand(99999),
            'name'                => app,
            'owner_email'         => 'email@example.com',
            'stack'               => request_params[:query].has_key?('app[stack]') && request_params[:query]['app[stack]'] || 'bamboo-mri-1.9.2',
            'slug_size'           => nil,
            'requested_stack'     => nil,
            'git_url'             => "git@heroku.com:#{app}.git",
            'repo_migrate_status' => 'complete',
            'repo_size'           => nil,
            'dynos'               => 0,
            'web_url'             => "http://#{app}.herokuapp.com/",
            'workers'             => 0

          }

          mock_data[:addons][app] = [
            {
              'beta'        => false,
              'configured'  => true,
              'description' => 'Basic Logging',
              'name'        => 'logging:basic',
              'state'       => 'public',
              'url'         => 'http://devcenter.heroku.com/articles/logging'
            },
            {
              'beta'        => false,
              'configured'  => true,
              'description' => 'Shared Database 5MB',
              'name'        => 'shared-database:5mb',
              'state'       => 'public',
              'url'         => nil
            },
          ]
          mock_data[:apps] << app_data
          mock_data[:collaborators][app] = [{
            'access' => 'edit',
            'email'  => 'email@example.com'
          }]
          mock_data[:config_vars][app] = {}
          mock_data[:domains][app] = []
          {
            :body   => Heroku::OkJson.encode(app_data),
            :status => 202
          }
        end
      end

      # stub POST /apps/:app/server/maintenance
      Excon.stub(:expects => 200, :method => :post, :path => %r{^/apps/([^/]+)/server/maintenance$}) do |params|
        request_params, mock_data = parse_stub_params(params)
        app, _ = request_params[:captures][:path].first

        with_mock_app(mock_data, app) do
          case request_params[:query]['maintenance_mode']
          when '0'
            mock_data[:maintenance_mode] -= [app]
          when '1'
            mock_data[:maintenance_mode] |= [app]
          end

          {
            :status => 200
          }
        end
      end

      # stub PUT /apps/:app
      Excon.stub(:expects => 200, :method => :put, :path => %r{^/apps/([^/]+)$} ) do |params|
        request_params, mock_data = parse_stub_params(params)
        app, _ = request_params[:captures][:path]

        with_mock_app(mock_data, app) do |app_data|
          if request_params[:query].has_key?('app[name]')
            app_data['name'] = request_params[:query]['app[name]']
          end
          if request_params[:query].has_key?('app[transfer_owner]')
            email = request_params[:query]['app[transfer_owner]']
            if collaborator = get_mock_collaborator(mock_data, app, email)
              app_data['owner_email'] = email
            end
          end
          if email && !collaborator
            {
              :body   => Heroku::OkJson.encode('error' => 'Only existing collaborators can receive ownership for an app'),
              :status => 422
            }
          else
            {
              :body   => Heroku::OkJson.encode('name' => app_data['name']),
              :status => 200
            }
          end
        end
      end

    end
  end
end
