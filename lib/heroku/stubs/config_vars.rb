module Heroku
  class API < Excon::Connection
    module Mock

      # stub DELETE /apps/:app/config_vars/:key
      Excon.stub(:expects => 200, :method => :delete, :path => %r{^/apps/([^/]+)/config_vars/([^/]+)$}) do |params|
        request_params, mock_data = parse_stub_params(params)
        app, key, _ = request_params[:captures][:path]
        with_mock_app(mock_data, app) do
          mock_data[:config_vars][app].delete(key)
          {
            :body   => HerokuAPI::OkJson.encode(mock_data[:config_vars][app]),
            :status => 200
          }
        end
      end

      # stub GET /apps/:app/config_vars
      Excon.stub(:expects => 200, :method => :get, :path => %r{^/apps/([^/]+)/config_vars$}) do |params|
        request_params, mock_data = parse_stub_params(params)
        app, _ = request_params[:captures][:path]
        with_mock_app(mock_data, app) do
          {
            :body   => HerokuAPI::OkJson.encode(mock_data[:config_vars][app]),
            :status => 200
          }
        end
      end

      # stub PUT /apps/:app/config_vars
      Excon.stub(:expects => 200, :method => :put, :path => %r{^/apps/([^/]+)/config_vars$}) do |params|
        request_params, mock_data = parse_stub_params(params)
        app, _ = request_params[:captures][:path]
        with_mock_app(mock_data, app) do
          new_config_vars = request_params[:body]
          mock_data[:config_vars][app].merge!(new_config_vars)
          {
            :body   => HerokuAPI::OkJson.encode(mock_data[:config_vars][app]),
            :status => 200
          }
        end
      end

    end
  end
end
