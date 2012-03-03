module Heroku
  class API

    # GET /user
    def get_user
      request(
        :expects  => 200,
        :method   => :get,
        :path     => "/user"
      )
    end

  end
end
