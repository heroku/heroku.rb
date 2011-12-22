module Heroku
  class API < Excon::Connection

    # GET /apps/:app/logs
    def get_logs(app, options)
      request(
        :expects  => 200,
        :method   => :get,
        :path     => "/apps/#{app}/logs",
        :query    => options
      )
    end

  end
end
