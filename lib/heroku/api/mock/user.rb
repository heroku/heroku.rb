module Heroku
  class API
    module Mock

      # stub GET /user
      Excon.stub(:expects => 200, :method => :get, :path => %r{^/user}) do |params|
        request_params, mock_data = parse_stub_params(params)
        {
          :body   => Heroku::API::OkJson.encode(mock_data[:user]),
          :status => 200
        }
      end

    end
  end
end
