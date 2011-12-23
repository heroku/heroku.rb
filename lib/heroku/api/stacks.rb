module Heroku
  class API < Excon::Connection

    def get_stack(app)
      request(
        :expects  => 200,
        :method   => :get,
        :path     => "/apps/#{app}/stack"
      )
    end

    def put_stack(app, stack)
      request(
        :expects  => 200,
        :method   => :put,
        :path     => "/apps/#{app}/stack",
        :query    => {'body' => stack}
      )
    end

  end
end
