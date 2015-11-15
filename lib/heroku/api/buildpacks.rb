module Heroku
  class API

    # PUT /apps/:buildpack
    def put_buildpacks(app, buildpacks=[])
      request(
        :headers  => {'Accept' => "application/vnd.heroku+json; version=3", 'Conent-Type' => 'application/json'},
        :expects  => 200,
        :method   => :put,
        :path     => "/apps/#{app}/buildpack-installations",
        :body     => MultiJson.dump({"updates" => buildpacks.map{|bp| {"buildpack"=>bp}}})
      )
    end

    def get_buildpacks(app)
      request(
        :headers  => {'Accept' => "application/vnd.heroku+json; version=3", 'Conent-Type' => 'application/json'},
        :expects  => 200,
        :method   => :get,
        :path     => "/apps/#{app}/buildpack-installations"
      )
    end

  end
end
