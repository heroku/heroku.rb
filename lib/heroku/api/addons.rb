module Heroku
  class API

    # DELETE /apps/:app/addons/:addon
    def delete_addon(app, addon)
      request(
        :expects  => 200,
        :method   => :delete,
        :path     => "/apps/#{app}/addons/#{addon}"
      )
    end

    # GET /addons
    # GET /apps/:app/addons
    def get_addons(app=nil)
      path = if app
        "/apps/#{app}/addons"
      else
        "/addons"
      end
      request(
        :expects  => 200,
        :method   => :get,
        :path     => path
      )
    end

    # POST /apps/:app/addons/:addon
    def post_addon(app, addon, config = {})
      request(
        :expects  => 200,
        :method   => :post,
        :path     => "/apps/#{app}/addons/#{addon}",
        :query    => addon_params(config)
      )
    end

    # PUT /apps/:app/addons/:addon
    def put_addon(app, addon, config = {})
      request(
        :expects  => 200,
        :method   => :put,
        :path     => "/apps/#{app}/addons/#{addon}",
        :query    => addon_params(config)
      )
    end
  end
end
