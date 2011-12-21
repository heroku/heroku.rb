module Heroku
  class API < Excon::Connection

    # DELETE /apps/:name
    def delete_app(name)
      request(:expects => 200, :method => :delete, :path => "/apps/#{name}")
    end

    # GET /apps
    def get_apps
      request(:expects => 200, :method => :get, :path => "/apps")
    end

    # GET /apps/:name
    def get_app(name)
      request(:expects => 200, :method => :get, :path => "/apps/#{name}")
    end

    # POST /apps
    def post_app(params={})
      request(:body => {'app' => params}, :expects => 202, :method => :post, :path => '/apps')
    end

    # POST /apps/:name/server/maintenance
    def post_app_server_maintenance(name, new_server_maintenance)
      body = "maintenance_mode=#{new_server_maintenance}"
      request(:body => body, :expects => 200, :method => :post, :path => "/apps/#{name}/server/maintenance")
    end

    # PUT /apps/:name
    def put_app(name, params)
      request(:body => {'app' => params}, :expects => 200, :method => :put, :path => "/apps/#{name}")
    end

  end
end
