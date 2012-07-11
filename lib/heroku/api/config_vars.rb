module Heroku
  class API

    # DELETE /apps/:app/config_vars/:key
    def delete_config_var(app, key)
      request(
        :expects  => 200,
        :method   => :delete,
        :path     => "/apps/#{app}/config_vars/#{key}"
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
        :body     => Heroku::API::OkJson.encode(vars),
        :expects  => 200,
        :method   => :put,
        :path     => "/apps/#{app}/config_vars"
      )
    end

  end
end
