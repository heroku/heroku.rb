module Heroku
  class API < Excon::Connection

    # DELETE /user/keys/:key
    def delete_key(key)
      request(
        :expects  => 200,
        :method   => :delete,
        :path     => "/user/keys/#{CGI.escape(key)}"
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
        :expects  => 200,
        :method   => :post,
        :path     => "/user/keys",
        :query    => {'body' => key}
      )
    end

  end
end
