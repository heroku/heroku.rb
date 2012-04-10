module Heroku
  class API
    module Mock

      # stub DELETE /user/keys/:key
      Excon.stub(:expects => 200, :method => :delete, :path => %r{^/user/keys/([^/]+)}) do |params|
        request_params, mock_data = parse_stub_params(params)
        key, _ = request_params[:captures][:path]
        key = CGI.unescape(key).gsub('%2E', '.')
        if key_data = get_mock_key(mock_data, key)
          mock_data[:keys].delete(key_data)
          { :status => 200 }
        else
          { :body => "Key not found.", :status => 404 }
        end
      end

      # stub DELETE /user/keys
      Excon.stub(:expects => 200, :method => :delete, :path => %r{^/user/keys}) do |params|
        request_params, mock_data = parse_stub_params(params)
        mock_data[:keys] = []
        { :status => 200}
      end

      # stub GET /user/keys
      Excon.stub(:expects => 200, :method => :get, :path => %r{^/user/keys}) do |params|
        request_params, mock_data = parse_stub_params(params)
        {
          :body   => Heroku::API::OkJson.encode(mock_data[:keys]),
          :status => 200
        }
      end

      # stub POST /user/keys
      Excon.stub(:expects => 200, :method => :post, :path => %r{^/user/keys}) do |params|
        request_params, mock_data = parse_stub_params(params)
        mock_data[:keys] |= [{
          'email'     => 'email@example.com',
          'contents'  => request_params[:body]
        }]
        { :status => 200 }
      end

    end
  end
end
