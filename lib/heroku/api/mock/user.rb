module Heroku
  class API
    module Mock

      # stub GET /user
      Excon.stub(:expects => 200, :method => :get, :path => %r{^/user$}) do |params|
        request_params, mock_data = parse_stub_params(params)
        {
          :body   => File.read("#{File.dirname(__FILE__)}/cache/get_user.json"),
          :status => 200
        }
      end

    end
  end
end
