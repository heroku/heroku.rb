module Heroku
  class API

    # DELETE /user/keys/:key
    def delete_key(key)
      request(
        :expects  => 200,
        :method   => :delete,
        :path     => "/user/keys/#{escape(key)}"
      )
    end

    # DELETE /user/keys
    def delete_keys
      request(
        :expects  => 200,
        :method   => :delete,
        :path     => "/user/keys"
      )
    end

    # GET /user/keys
    def get_keys
      request(
        :expects  => 200,
        :method   => :get,
        :path     => "/user/keys"
      )
    end

    # POST /user/keys
    def post_key(key)
      request(
        :body     => key,
        :expects  => 200,
        :method   => :post,
        :path     => "/user/keys"
      )
    end

  end
end
