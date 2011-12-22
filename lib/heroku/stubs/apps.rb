module Heroku
  class API < Excon::Connection

    # stub DELETE /apps/:app
    Excon.stub(:expects => 200, :method => :delete, :path => %r{^/apps/([^/]+)$} ) do |params|
      request_params, mock_data = parse_stub_params(params)
      app, _ = request_params[:captures][:path]
      if app_data = mock_data[:apps].detect {|app_data| app_data['name'] == app}
        mock_data[:apps].delete(app_data)
        mock_data[:config_vars].delete(app)
        {
          :body   => Heroku::OkJson.encode({}),
          :status => 200
        }
      else
        APP_NOT_FOUND
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
      if app_data = mock_data[:apps].detect {|app_data| app_data['name'] == app}
        {
          :body   => Heroku::OkJson.encode(app_data),
          :status => 200
        }
      else
        APP_NOT_FOUND
      end
    end

    # stub POST /apps
    Excon.stub(:expects => 202, :method => :post, :path => '/apps') do |params|
      request_params, mock_data = parse_stub_params(params)
      app = request_params[:body].has_key?('app[name]') && request_params[:body]['app[name]'] || "generated-name-#{rand(999)}"

      if mock_data[:apps].detect {|app_data| app_data['name'] == app}
        {
          :body => Heroku::OkJson.encode('error' => 'Name is already taken'),
          :status => 422
        }
      else
        app_data = {
          'created_at'          => Time.now.strftime("%G/%d/%m %H:%M:%S %z"),
          'create_status'       => 'complete',
          'id'                  => rand(99999),
          'name'                => app,
          'owner_email'         => 'email@example.com',
          'stack'               => request_params[:body].has_key?('app[stack]') && request_params[:body]['app[stack]'] || 'bamboo-mri-1.9.2',
          'slug_size'           => nil,
          'requested_stack'     => nil,
          'git_url'             => "git@heroku.com:#{app}.git",
          'repo_migrate_status' => 'complete',
          'repo_size'           => nil,
          'dynos'               => 0,
          'web_url'             => "http://#{app}.herokuapp.com/",
          'workers'             => 0

        }

        mock_data[:apps] << app_data
        mock_data[:config_vars][app] = {}
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

      app_data = mock_data[:apps].detect {|app_data| app_data['name'] == app}

      if app_data.nil?
        case request_params[:body]['maintenance_mode']
        when '0'
          mock_data[:body][:maintenance_mode] -= [app]
        when '1'
          mock_data[:body][:maintenance_mode] |= [app]
        end

        {
          :status => 200
        }
      else
        APP_NOT_FOUND
      end
    end

    # stub PUT /apps/:app
    Excon.stub(:expects => 200, :method => :put, :path => %r{^/apps/([^/]+)$} ) do |params|
      request_params, mock_data = parse_stub_params(params)
      app, _ = request_params[:captures][:path]

      if app_data = mock_data[:apps].detect {|app_data| app_data['name'] == app}
        app_data['name'] = request_params[:body]['app[name]']
        {
          :body   => Heroku::OkJson.encode('name' => request_params[:body]['app[name]']),
          :status => 200
        }
      else
        APP_NOT_FOUND
      end
    end

  end
end
