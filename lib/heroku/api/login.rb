module Heroku
  class API

    def post_login(username, password)
      request(
        :expects  => 200,
        :method   => :post,
        :path     => '/login',
        :query    => { 'username' => username, 'password' => password }
      )
    end

  end
end
