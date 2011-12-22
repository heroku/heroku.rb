module Heroku
  class API < Excon::Connection
    module Mock

      # stub DELETE /apps/:app/config_vars/:key
      Excon.stub(:expects => 200, :method => :delete, :path => %r{^/apps/([^/]+)/config_vars/([^/]+)$}) do |params|
        request_params, mock_data = parse_stub_params(params)
        app, key, _ = request_params[:captures][:path]
        if mock_data[:apps].detect {|app_data| app_data['name'] == app}
          mock_data[:config_vars][app].delete(key)
          {
            :body   => Heroku::OkJson.encode(mock_data[:config_vars][app]),
            :status => 200
          }
        else
          APP_NOT_FOUND
        end
      end

      # stub GET /apps/:app/config_vars
      Excon.stub(:expects => 200, :method => :get, :path => %r{^/apps/([^/]+)/config_vars$}) do |params|
        request_params, mock_data = parse_stub_params(params)
        app, _ = request_params[:captures][:path]
        if mock_data[:apps].detect {|app_data| app_data['name'] == app}
          {
            :body   => Heroku::OkJson.encode(mock_data[:config_vars][app]),
            :status => 200
          }
        else
          APP_NOT_FOUND
        end
      end

      # stub PUT /apps/:app/config_vars
      Excon.stub(:expects => 200, :method => :put, :path => %r{^/apps/([^/]+)/config_vars$}) do |params|
        request_params, mock_data = parse_stub_params(params)
        app, _ = request_params[:captures][:path]
        if mock_data[:apps].detect {|app_data| app_data['name'] == app}
          mock_data[:config_vars][app].merge!(request_params[:body])
          {
            :body   => Heroku::OkJson.encode(mock_data[:config_vars][app]),
            :status => 200
          }
        else
          APP_NOT_FOUND
        end
      end

    end
  end
end
