module Heroku
  class API < Excon::Connection

    # DELETE /apps/:name/config_vars/:key
    def delete_app_config_var(name, key)
      request(:expects => 200, :method => :delete, :path => "/apps/#{name}/config_vars/#{key}")
    end

    # GET /apps/:name/config_vars
    def get_app_config_vars(name)
      request(:expects => 200, :method => :get, :path => "/apps/#{name}/config_vars")
    end

    # PUT /apps/:name/config_vars
    def put_app_config_vars(name, vars)
      request(:body => Heroku::OkJson.encode(vars), :expects => 200, :method => :put, :path => "/apps/#{name}/config_vars")
    end

  end
end
