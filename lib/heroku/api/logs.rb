module Heroku
  class API

    # GET /apps/:app/logs
    def get_logs(app, options = {})
      options = {
        'logplex' => 'true'
      }.merge(options)
      request(
        :expects  => 200,
        :method   => :get,
        :path     => "/apps/#{app}/logs",
        :query    => options
      )
    end

  end
end
