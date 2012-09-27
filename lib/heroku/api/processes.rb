module Heroku
  class API

    def get_ps(app)
      deprecate('get_ps is deprecated, use get_dynos(app).')
      get_dynos(app)
    end

    def post_ps(app, command, options={})
      deprecate('post_ps is deprecated, use post_dynos(app, command, options={}).')
      post_dynos(app, command, options)
    end

    def post_ps_restart(app, options={})
      deprecate('post_ps_restart is deprecated, use delete_dynos(app, options={}).')
      delete_dynos(app, options={})
    end

    # POST /apps/:app/ps/scale
    def post_ps_scale(app, type, quantity)
      deprecate('post_ps_scale is deprecated, use put_dyno_types(app, types).')
      put_dyno_types(app, [{'name' => type, 'quantity' => quantity}])
    end

    def post_ps_stop(app, options)
      deprecate('post_ps_restart is deprecated, use delete_dynos(app, options={}).')
      delete_dynos(app, options={})
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
