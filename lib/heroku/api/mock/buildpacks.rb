module Heroku
  class API
    module Mock

      # stub PUT /apps/:app/buildpack-installations
      Excon.stub(:expects => 200, :method => :put, :path => %r{^/apps/([^/]+)/buildpack-installations$}) do |params|
        request_params, mock_data = parse_stub_params(params)
        app, _ = request_params[:captures][:path]

        with_mock_app(mock_data, app) do |app_data|
          {
            :body   => "",
            :status => 200
          }
        end
      end
    end
  end
end
