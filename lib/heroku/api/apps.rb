module Heroku
  class API < Excon::Connection

    # DELETE /apps/:app
    def delete_app(app)
      request(:expects => 200, :method => :delete, :path => "/apps/#{app}")
    end

    # GET /apps
    def get_apps
      request(:expects => 200, :method => :get, :path => "/apps")
    end

    # GET /apps/:app
    def get_app(app)
      request(:expects => 200, :method => :get, :path => "/apps/#{app}")
    end

    # POST /apps
    def post_app(params={})
      request(:body => {'app' => params}, :expects => 202, :method => :post, :path => '/apps')
    end

    # POST /apps/:app/server/maintenance
    def post_app_server_maintenance(app, new_server_maintenance)
      body = "maintenance_mode=#{new_server_maintenance}"
      request(:body => body, :expects => 200, :method => :post, :path => "/apps/#{app}/server/maintenance")
    end

    # PUT /apps/:app
    def put_app(app, params)
      request(:body => {'app' => params}, :expects => 200, :method => :put, :path => "/apps/#{app}")
    end

  end
end
