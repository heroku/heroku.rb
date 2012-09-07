module Heroku
  class API

    # DELETE /features/:feature
    def delete_feature(feature, app = nil)
      request(
        :expects  => 200,
        :method   => :delete,
        :path     => "/features/#{feature}",
        :query    => { 'app' => app }
      )
    end

    # GET /features
    def get_features(app = nil)
      request(
        :expects  => 200,
        :method   => :get,
        :path     => "/features",
        :query    => { 'app' => app }
      )
    end

    # GET /features/:feature
    def get_feature(feature, app = nil)
      request(
        :expects  => 200,
        :method   => :get,
        :path     => "/features/#{feature}",
        :query    => { 'app' => app }
      )
    end

    # POST /features/:feature
    def post_feature(feature, app = nil)
      request(
        :expects  => [200, 201],
        :method   => :post,
        :path     => "/features/#{feature}",
        :query    => { 'app' => app }
      )
    end

  end
end
