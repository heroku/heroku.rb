module Heroku
  class API

    def post_login(username, password)
      request(
        :expects  => 200,
        :method   => :post,
        :path     => '/login',
        :body     => URI.encode_www_form(:username => username, :password => password),
        :headers  => { "Content-Type" => "application/x-www-form-urlencoded" }
      )
    end

  end
end
