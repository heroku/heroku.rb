module Heroku
  class API

    # PUT /apps/:app/dyno-types
    def put_dyno_types(app, types)
      request(
        :expects  => 200,
        :method   => :put,
        :path     => "/apps/#{app}/dyno-types",
        :query    => {
          'dyno_types' => Heroku::API::OkJson.encode(types)
        }
      )
    end

  end
end
