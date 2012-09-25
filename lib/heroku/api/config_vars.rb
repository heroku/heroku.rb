module Heroku
  class API

    # DELETE /apps/:app/config_vars/:key
    def delete_config_var(app, key)
      deprecate("delete_config_var is deprecated, use delete_config_vars(app, key)")
      request(
        :expects  => 200,
        :method   => :delete,
        :path     => "/apps/#{app}/config_vars/#{escape(key)}"
      )
    end

    # DELETE /apps/:app/config_vars
    def delete_config_vars(app, keys)
      request(
        :expects  => 200,
        :method   => :delete,
        :path     => "/apps/#{app}/config-vars",
        :query    => [*keys].map {|key| "config_vars[]=#{key}"}.join('&')
      )
    end

    # GET /apps/:app/config_vars
    def get_config_vars(app)
      request(
        :expects  => 200,
        :method   => :get,
        :path     => "/apps/#{app}/config_vars"
      )
    end

    # PUT /apps/:app/config_vars
    def put_config_vars(app, vars)
      request(
        :expects  => 200,
        :method   => :put,
        :path     => "/apps/#{app}/config_vars",
        :query    => config_vars_params(vars)
      )
    end

  end
end
