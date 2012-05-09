module Heroku
  class API
    module Mock

      # stub POST /login
      Excon.stub(:expects => 200, :method => :post, :path => '/login') do |params|
        request_params, mock_data = parse_stub_params(params)
        {
          :body   => {
            'api_key'     => SecureRandom.hex(20),
            'email'       => 'email@example.com',
            'id'          => '123456@users.heroku.com',
            'verified'    => true,
            'verified_at' => timestamp
          },
          :status => 200
        }
      end

    end
  end
end
