module Heroku
  class API < Excon::Connection
    module Mock

      # stub GET /apps/:app/logs
      Excon.stub(:expects => 200, :method => :get, :path => %r{^/apps/([^/]+)/logs}) do |params|
        request_params, mock_data = parse_stub_params(params)
        app, _ = request_params[:captures][:path]
        with_mock_app(mock_data, app) do
          {
            :body   => "https://logplex.heroku.com/sessions/#{SecureRandom.uuid}?srv=#{Time.now.to_i}",
            :status => 200
          }
        end
      end

    end
  end
end
