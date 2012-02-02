module Heroku
  class API

    # GET /apps/:app/ps
    def get_ps(app)
      request(
        :expects  => 200,
        :method   => :get,
        :path     => "/apps/#{app}/ps"
      )
    end

    # POST /apps/:app/ps
    def post_ps(app, command, options={})
      query = { 'command' => command }.merge(options)
      request(
        :expects  => 200,
        :method   => :post,
        :path     => "/apps/#{app}/ps",
        :query    => query
      )
    end

    # POST /apps/:app/ps/restart
    def post_ps_restart(app, options={})
      request(
        :expects  => 200,
        :method   => :post,
        :path     => "/apps/#{app}/ps/restart",
        :query    => options
      )
    end

    # POST /apps/:app/ps/scale
    def post_ps_scale(app, type, quantity)
      request(
        :expects  => 200,
        :method   => :post,
        :path     => "/apps/#{app}/ps/scale",
        :query    => {
          'type'  => type,
          'qty'   => quantity
        }
      )
    end

    # POST /apps/:app/ps/stop
    def post_ps_stop(app, options)
      request(
        :expects  => 200,
        :method   => :post,
        :path     => "/apps/#{app}/ps/stop",
        :query    => options
      )
    end

    # PUT /apps/:app/dynos
    def put_dynos(app, dynos)
      request(
        :expects  => 200,
        :method   => :put,
        :path     => "/apps/#{app}/dynos",
        :query    => {'dynos' => dynos}
      )
    end

    # PUT /apps/:app/workers
    def put_workers(app, workers)
      request(
        :expects  => 200,
        :method   => :put,
        :path     => "/apps/#{app}/workers",
        :query    => {'workers' => workers}
      )
    end
  end
end
