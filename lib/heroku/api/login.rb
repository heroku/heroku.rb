module Heroku
  class API

    def post_login(username, password)
      request(
        :expects  => 200,
        :method   => :post,
        :path     => '/login',
        :body     => "username=#{URI.encode(username)}&password=#{URI.encode(password)}",
        :headers  => { "Content-Type" => "application/x-www-form-urlencoded" }
      )
    end

  end
end
