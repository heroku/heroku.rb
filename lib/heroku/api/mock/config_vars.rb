module Heroku
  class API
    module Mock

      # stub DELETE /apps/:app/config_vars/:key
      Excon.stub(:expects => 200, :method => :delete, :path => %r{^/apps/([^/]+)/config_vars/([^/]+)$}) do |params|
        request_params, mock_data = parse_stub_params(params)
        app, key, _ = request_params[:captures][:path]
        key = unescape(key)
        with_mock_app(mock_data, app) do
          mock_data[:config_vars][app].delete(key)
          add_mock_release(mock_data, app, {'descr' => "Config remove #{key}"})
          {
            :body   => MultiJson.encode(mock_data[:config_vars][app]),
            :status => 200
          }
        end
      end

      # stub DELETE /apps/:app/config_vars
      Excon.stub(:expects => 200, :method => :delete, :path => %r{^/apps/([^/]+)/config-vars$}) do |params|
        request_params, mock_data = parse_stub_params(params)
        app, _ = request_params[:captures][:path]
        with_mock_app(mock_data, app) do
          keys = request_params[:query].split('&').map {|pair| pair.split('=', 2).last}
          keys.each do |key|
            mock_data[:config_vars][app].delete(key)
          end
          add_mock_release(mock_data, app, {'descr' => "Remove #{keys.join(', ')} config"})
          {
            :body   => MultiJson.encode(mock_data[:config_vars][app]),
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
            :body   => MultiJson.encode(mock_data[:config_vars][app]),
            :status => 200
          }
        end
      end

      # stub PUT /apps/:app/config_vars
      Excon.stub(:expects => 200, :method => :put, :path => %r{^/apps/([^/]+)/config_vars$}) do |params|
        request_params, mock_data = parse_stub_params(params)
        app, _ = request_params[:captures][:path]
        with_mock_app(mock_data, app) do
          new_config_vars = {}
          request_params[:query].each do |key, value|
            key =~ /^config_vars\[([^\]]*)\]$/
            new_config_vars[$1] = value
          end
          mock_data[:config_vars][app].merge!(new_config_vars)
          add_mock_release(mock_data, app, {'descr' => "Add #{new_config_vars.keys.join(', ')} config"})
          {
            :body   => MultiJson.encode(mock_data[:config_vars][app]),
            :status => 200
          }
        end
      end

    end
  end
end
