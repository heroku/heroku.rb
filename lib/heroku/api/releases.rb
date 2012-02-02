module Heroku
  class API

    # GET /apps/:app/releases
    def get_releases(app)
      request(
        :expects  => 200,
        :method   => :get,
        :path     => "/apps/#{app}/releases"
      )
    end

    # GET /apps/:app/releases/:release
    def get_release(app, release)
      request(
        :expects  => 200,
        :method   => :get,
        :path     => "/apps/#{app}/releases/#{release}"
      )
    end

    # POST /apps/:app/releases/:release
    def post_release(app, release)
      request(
        :expects  => 200,
        :method   => :post,
        :path     => "/apps/#{app}/releases",
        :query    => {'rollback' => release}
      )
    end

  end
end
