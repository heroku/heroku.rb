module Heroku
  class API

    # DELETE /apps/:app/dynos
    def delete_dynos(app, options={})
      request(
        :expects  => 200,
        :method   => :delete,
        :path     => "/apps/#{app}/dynos",
        :query    => options
      )
    end

    # GET /apps/:app/dynos
    def get_dynos(app)
      request(
        :expects  => 200,
        :method   => :get,
        :path     => "/apps/#{app}/dynos"
      )
    end

    # POST /apps/:app/dynos
    def post_dynos(app, command, options={})
      attach = options.delete('attach') || options.delete(:attach)
      options = { 'command' => command }.merge(options)
      if attach
        options['attach'] = attach
      end
      request(
        :expects  => 200,
        :method   => :post,
        :path     => "/apps/#{app}/dynos",
        :query    => dynos_params(options)
      )
    end

    # PUT /apps/:app/dynos
    def put_dynos(app, dynos)
      request(
        :expects  => 200,
        :method   => :put,
        :path     => "/apps/#{app}/dynos",
        :query    => {'dynos' => dynos}
      )
    end

  end
end
