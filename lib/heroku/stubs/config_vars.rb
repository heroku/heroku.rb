module Heroku
  class API < Excon::Connection
    CONFIG_VAR_REGEX = %r{^/apps/([^/]+)/config_vars$}

    # stub DELETE /apps/:name/config_vars/:key
    Excon.stub(:expects => 200, :method => :delete, :path => %r{#{CONFIG_VAR_REGEX.to_s.gsub('$','')}/([^/]+)$}) do |params|
      request_params, mock_data = parse_stub_params(params)
      name, key, _ = %r{#{CONFIG_VAR_REGEX.to_s.gsub('$','')}/([^/]+)$}.match(request_params[:path]).captures
      if app = mock_data[:apps].detect {|app| app['name'] == name}
        mock_data[:config_vars][name].delete(key)
        {
          :body   => Heroku::OkJson.encode(mock_data[:config_vars][name]),
          :status => 200
        }
      else
        APP_NOT_FOUND
      end
    end

    # stub GET /apps/:name/config_vars
    Excon.stub(:expects => 200, :method => :get, :path => CONFIG_VAR_REGEX) do |params|
      request_params, mock_data = parse_stub_params(params)
      name, _ = CONFIG_VAR_REGEX.match(request_params[:path]).captures
      if app = mock_data[:apps].detect {|app| app['name'] == name}
        {
          :body   => Heroku::OkJson.encode(mock_data[:config_vars][name]),
          :status => 200
        }
      else
        APP_NOT_FOUND
      end
    end

    # stub PUT /apps/:name/config_vars
    Excon.stub(:expects => 200, :method => :put, :path => CONFIG_VAR_REGEX) do |params|
      request_params, mock_data = parse_stub_params(params)
      name, _ = CONFIG_VAR_REGEX.match(request_params[:path]).captures
      if app = mock_data[:apps].detect {|app| app['name'] == name}
        mock_data[:config_vars][name].merge!(request_params[:body])
        {
          :body   => Heroku::OkJson.encode(mock_data[:config_vars][name]),
          :status => 200
        }
      else
        APP_NOT_FOUND
      end
    end

  end
end
