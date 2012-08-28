module Heroku
  class API
    module Mock

      # stub DELETE /apps/:app
      Excon.stub(:expects => 200, :method => :delete, :path => %r{^/apps/([^/]+)$} ) do |params|
        request_params, mock_data = parse_stub_params(params)
        app, _ = request_params[:captures][:path]
        with_mock_app(mock_data, app) do |app_data|
          mock_data[:addons].delete(app)
          mock_data[:apps].delete(app_data)
          mock_data[:attachments].delete(app)
          mock_data[:collaborators].delete(app)
          mock_data[:config_vars].delete(app)
          mock_data[:domains].delete(app)
          mock_data[:maintenance_mode].delete(app)
          mock_data[:ps].delete(app)
          mock_data[:releases].delete(app)
          {
            :body   => Heroku::API::OkJson.encode({}),
            :status => 200
          }
        end
      end

      # stub GET /apps/
      Excon.stub(:expects => 200, :method => :get, :path => '/apps') do |params|
        request_params, mock_data = parse_stub_params(params)
        {
          :body   => Heroku::API::OkJson.encode(mock_data[:apps]),
          :status => 200
        }
      end

      # stub GET /apps/:app
      Excon.stub(:expects => 200, :method => :get, :path => %r{^/apps/([^/]+)$} ) do |params|
        request_params, mock_data = parse_stub_params(params)
        app, _ = request_params[:captures][:path]
        with_mock_app(mock_data, app) do |app_data|
          {
            :body   => Heroku::API::OkJson.encode(app_data),
            :status => 200
          }
        end
      end

      # stub GET /apps/:app/server/maintenance
      Excon.stub(:expects => 200, :method => :get, :path => %r{^/apps/([^/]+)/server/maintenance$}) do |params|
        request_params, mock_data = parse_stub_params(params)
        app, _ = request_params[:captures][:path].first

        with_mock_app(mock_data, app) do
          maintenance = mock_data[:maintenance_mode].include?(app)
          {
            :body   => Heroku::API::OkJson.encode('maintenance' => maintenance),
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
            :body => Heroku::API::OkJson.encode('error' => 'Name is already taken'),
            :status => 422
          }
        else
          stack = request_params[:query].has_key?('app[stack]') && request_params[:query]['app[stack]'] || 'bamboo-mri-1.9.2'
          app_data = {
            'created_at'          => timestamp,
            'create_status'       => 'complete',
            'id'                  => rand(99999),
            'name'                => app,
            'owner_email'         => 'email@example.com',
            'slug_size'           => nil,
            'stack'               => stack,
            'requested_stack'     => nil,
            'git_url'             => "git@heroku.com:#{app}.git",
            'repo_migrate_status' => 'complete',
            'repo_size'           => nil,
            'dynos'               => 0,
            'web_url'             => "http://#{app}.herokuapp.com/",
            'workers'             => 0
          }

          mock_data[:addons][app] = []
          mock_data[:apps] << app_data
          mock_data[:attachments][app] = []
          mock_data[:collaborators][app] = [{
            'access' => 'edit',
            'email'  => 'email@example.com',
            'name'   => nil
          }]
          mock_data[:config_vars][app] = {}
          mock_data[:domains][app] = []
          mock_data[:ps][app] = [{
            'action'          => 'up',
            'app_name'        => app,
            'attached'        => false,
            'command'         => nil, # set by stack below
            'elapsed'         => 0,
            'pretty_state'    => 'created for 0s',
            'process'         => 'web.1',
            'rendezvous_url'  => nil,
            'slug'            => 'NONE',
            'state'           => 'created',
            'transitioned_at' => app_data['created_at'],
            'type'            => nil, # set by stack below
            'upid'            => rand(99999999).to_s
          }]
          mock_data[:releases][app] = []

          if stack == 'cedar'
            mock_data[:ps][app].first['command'] = 'bundle exec thin start -p $PORT'
            mock_data[:ps][app].first['type'] = 'Ps'
          else
            add_mock_app_addon(mock_data, app, 'shared-database:5mb')
            mock_data[:config_vars][app] = {
              'BUNDLE_WITHOUT' => 'development:test',
              'LANG' => 'en_US.UTF-8',
              'RACK_ENV' => 'production'
            }
            mock_data[:ps][app].first['command']  = 'thin -p $PORT -e $RACK_ENV -R $HEROKU_RACK start'
            mock_data[:ps][app].first['type']     = 'Dyno'
          end

          {
            :body   => Heroku::API::OkJson.encode(app_data),
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
      Excon.stub(:expects => 200, :method => :put, :path => %r{^/apps/([^/]+)$}) do |params|
        request_params, mock_data = parse_stub_params(params)
        app, _ = request_params[:captures][:path]

        with_mock_app(mock_data, app) do |app_data|
          if request_params[:query].has_key?('app[name]')
            name = request_params[:query]['app[name]']
            app_data['git_url'] = "git@heroku.com:#{name}.git"
            app_data['name'] = name
            app_data['web_url'] = "http://#{name}.herokuapp.com/"
          end
          if request_params[:query].has_key?('app[transfer_owner]')
            email = request_params[:query]['app[transfer_owner]']
            if collaborator = get_mock_collaborator(mock_data, app, email)
              app_data['owner_email'] = email
            end
          end
          if email && !collaborator
            {
              :body   => Heroku::API::OkJson.encode('error' => 'Only existing collaborators can receive ownership for an app'),
              :status => 422
            }
          else
            {
              :body   => Heroku::API::OkJson.encode('name' => app_data['name']),
              :status => 200
            }
          end
        end
      end

      # stub PUT /apps/:app/status
      Excon.stub(:method => :put, :path => %r{^/apps/([^/]+)/status}) do |params|
        request_params, mock_data = parse_stub_params(params)
        app, _ = request_params[:captures][:path]

        with_mock_app(mock_data, app) do |app_data|
          {
            :body   => Heroku::API::OkJson.encode({}),
            :status => 201
          }
        end
      end

    end
  end
end
