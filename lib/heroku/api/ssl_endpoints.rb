module Heroku
  class API

    # DELETE /apps/:app/ssl-endpoint/:cname
    def delete_ssl_endpoint(app, cname)
      request(
        :expects  => 200,
        :method   => :delete,
        :path     => "/apps/#{app}/ssl-endpoints/#{escape(cname)}"
      )
    end

    # GET /apps/:app/ssl-endpoint/:cname
    def get_ssl_endpoint(app, cname)
      request(
        :expects  => 200,
        :method   => :get,
        :path     => "/apps/#{app}/ssl-endpoints/#{escape(cname)}"
      )
    end

    # GET /apps/:app/ssl-endpoints
    def get_ssl_endpoints(app)
      request(
        :expects  => 200,
        :method   => :get,
        :path     => "/apps/#{app}/ssl-endpoints"
      )
    end

    # POST /apps/:app/ssl-endpoints
    def post_ssl_endpoint(app, pem, key)
      request(
        :expects  => 200,
        :method   => :post,
        :path     => "/apps/#{app}/ssl-endpoints",
        :query     => { 'key' => key, 'pem' => pem }
      )
    end

    # POST /apps/:app/ssl-endpoints/:cname/rollback
    def post_ssl_endpoint_rollback(app, cname)
      request(
        :expects  => 200,
        :method   => :post,
        :path     => "/apps/#{app}/ssl-endpoints/#{escape(cname)}/rollback"
      )
    end

    # PUT /apps/:app/ssl-endpoints/:cname
    def put_ssl_endpoint(app, cname, pem, key)
      request(
        :expects  => 200,
        :method   => :put,
        :path     => "/apps/#{app}/ssl-endpoints/#{escape(cname)}",
        :query     => { 'key' => key, 'pem' => pem }
      )
    end

  end
end

