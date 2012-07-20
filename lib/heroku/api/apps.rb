module Heroku
  class API

    # DELETE /apps/:app
    def delete_app(app)
      request(
        :expects  => 200,
        :method   => :delete,
        :path     => "/apps/#{app}"
      )
    end

    # GET /apps
    def get_apps
      request(
        :expects  => 200,
        :method   => :get,
        :path     => "/apps"
      )
    end

    # GET /apps/:app
    def get_app(app)
      request(
        :expects  => 200,
        :method   => :get,
        :path     => "/apps/#{app}"
      )
    end

    # GET /apps/:app/server/maintenance
    def get_app_maintenance(app)
      request(
        :expects  => 200,
        :method   => :get,
        :path     => "/apps/#{app}/server/maintenance"
      )
    end

    # POST /apps
    def post_app(params={})
      request(
        :expects  => 202,
        :method   => :post,
        :path     => '/apps',
        :query    => app_params(params)
      )
    end

    # POST /apps/:app/server/maintenance
    def post_app_maintenance(app, maintenance_mode)
      request(
        :expects  => 200,
        :method   => :post,
        :path     => "/apps/#{app}/server/maintenance",
        :query    => {'maintenance_mode' => maintenance_mode}
      )
    end

    # PUT /apps/:app
    def put_app(app, params)
      request(
        :expects  => 200,
        :method   => :put,
        :path     => "/apps/#{app}",
        :query    => app_params(params)
      )
    end

  end
end
